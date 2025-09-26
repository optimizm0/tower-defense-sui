module tower_defense::game {
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};
    use sui::random::{Self, Random};
    use sui::event;
    use std::option::{Self, Option};

    // === Constants ===
    const BOSS_LEVEL_INTERVAL: u64 = 10;
    const UPGRADE_LEVEL_INTERVAL: u64 = 25;
    const MAX_UPGRADES: u64 = 4;
    const BASE_MONSTER_HP: u64 = 30;
    const BASE_MONSTER_DAMAGE: u64 = 15;
    const LEVEL_SCALING_FACTOR: u64 = 100; // Pour le calcul des gains
    const MONSTER_SCALING_RATE: u64 = 10 ; // +10% par niveau 
    
    // === Error codes ===
    const EInsufficientFunds: u64 = 1;
    const EGameNotStarted: u64 = 2;
    const EGameAlreadyStarted: u64 = 3;
    const EHeroDefeated: u64 = 4;
    const EInvalidBet: u64 = 5;
    const EUpgradeNotAvailable: u64 = 6;
    const EMaxUpgradesReached: u64 = 7;

    // === Structs ===
    
    /// Caractéristiques du héros
    struct HeroStats has copy, drop, store {
        hp: u64,
        max_hp: u64,
        damage: u64,
        attack_speed: u64, // Attaques par tour
        resistance: u64,   // Réduction de dégâts en %
        upgrades_used: u64,
    }

    /// Caractéristiques des monstres
    struct MonsterStats has copy, drop, store {
        hp: u64,
        max_hp: u64,
        damage: u64,
        monster_type: u8, // 0=normal, 1=boss
        reward: u64,
    }

    /// État du niveau actuel
    struct LevelState has copy, drop, store {
        current_level: u64,
        monsters_remaining: u64,
        current_monster: MonsterStats,
        is_boss_level: bool,
    }

    /// Objet principal du jeu
    struct GameSession has key, store {
        id: UID,
        player: address,
        hero: HeroStats,
        level_state: LevelState,
        bet_amount: u64,
        target_level: u64,
        game_active: bool,
        levels_completed: u64, // Pour calcul des gains finaux
    }

    /// Pool de paris global
    struct GamePool has key {
        id: UID,
        admin: address,
        total_pool: Balance<SUI>,
        house_edge: u64, // En pourcentage (ex: 5 = 5%)
    }

    /// Capacité d'administration
    struct AdminCap has key, store {
        id: UID,
    }

    // === Events ===
    
    struct GameStarted has copy, drop {
        player: address,
        hero_stats: HeroStats,
        bet_amount: u64,
        target_level: u64,
    }

    struct LevelCompleted has copy, drop {
        player: address,
        level: u64,
        reward: u64,
    }

    struct BossDefeated has copy, drop {
        player: address,
        boss_level: u64,
        bonus_reward: u64,
    }

    struct GameEnded has copy, drop {
        player: address,
        levels_completed: u64,
        bet_amount: u64,
        payout: u64,
        house_profit: u64,
    }

    struct HeroUpgraded has copy, drop {
        player: address,
        stat_upgraded: vector<u8>,
        new_stats: HeroStats,
    }

    // === Init Function ===
    
    fun init(ctx: &mut TxContext) {
        let admin_cap = AdminCap {
            id: object::new(ctx),
        };

        let game_pool = GamePool {
            id: object::new(ctx),
            admin: tx_context::sender(ctx),
            total_pool: balance::zero(),
            house_edge: 5,
        };

        transfer::transfer(admin_cap, tx_context::sender(ctx));
        transfer::share_object(game_pool);
    }

    // === Public Functions ===

    /// Démarre une nouvelle session de jeu
    public fun start_game(
        pool: &mut GamePool,
        bet: Coin<SUI>,
        target_level: u64,
        r: &Random,
        ctx: &mut TxContext
    ) {
        let bet_amount = coin::value(&bet);
        assert!(bet_amount > 0, EInvalidBet);
        
        // Ajouter les fonds au pool
        coin::put(&mut pool.total_pool, bet);
        
        // Générer les stats du héros aléatoirement (moyenne basse)
        let hero_stats = generate_random_hero_stats(r, ctx);
        
        // Créer l'état du premier niveau
        let level_state = create_level_state(1, r, ctx);
        
        let game_session = GameSession {
            id: object::new(ctx),
            player: tx_context::sender(ctx),
            hero: hero_stats,
            level_state,
            bet_amount,
            target_level,
            game_active: true,
            levels_completed: 0,
        };

        event::emit(GameStarted {
            player: tx_context::sender(ctx),
            hero_stats: game_session.hero,
            bet_amount,
            target_level,
        });

        transfer::transfer(game_session, tx_context::sender(ctx));
    }

    /// Combat contre le monstre actuel
    public fun fight_monster(
        game: &mut GameSession,
        pool: &mut GamePool,
        r: &Random,
        ctx: &mut TxContext
    ): Option<Coin<SUI>> {
        assert!(game.game_active, EGameNotStarted);
        assert!(game.hero.hp > 0, EHeroDefeated);

        // Simuler le combat
        let (hero_wins, hero_hp_remaining) = simulate_combat(
            &game.hero,
            &game.level_state.current_monster,
            r,
            ctx
        );

        if (hero_wins) {
            // Héros gagne - passer au niveau suivant
            if (game.level_state.is_boss_level) {
                event::emit(BossDefeated {
                    player: game.player,
                    boss_level: game.level_state.current_level,
                    bonus_reward: 0, // Pas de récompense immédiate
                });
            };

            event::emit(LevelCompleted {
                player: game.player,
                level: game.level_state.current_level,
                reward: 0, // Pas de récompense immédiate
            });

            game.levels_completed = game.level_state.current_level;

            // Vérifier si le joueur a atteint son objectif
            if (game.level_state.current_level >= game.target_level) {
                // Succès - paiement du gain
                option::some(end_game_with_payout(game, pool, ctx))
            } else {
                // Passer au niveau suivant
                advance_to_next_level(game, r, ctx);
                option::none()
            }
        } else {
            // Héros perd ou est blessé
            game.hero.hp = hero_hp_remaining;
            if (game.hero.hp == 0) {
                // Héros mort - fin du jeu, maison gagne
                end_game_hero_dead(game, pool, ctx);
                option::none()
            } else {
                option::none()
            }
        }
    }

    /// Améliorer les caractéristiques du héros
    public fun upgrade_hero(
        game: &mut GameSession,
        pool: &mut GamePool,
        payment: Coin<SUI>,
        stat_to_upgrade: vector<u8>, // 0=hp, 1=damage, 2=speed, 3=resistance
        ctx: &mut TxContext
    ) {
        assert!(game.game_active, EGameNotStarted);
        assert!(game.level_state.current_level % UPGRADE_LEVEL_INTERVAL == 0, EUpgradeNotAvailable);
        assert!(game.hero.upgrades_used < MAX_UPGRADES, EMaxUpgradesReached);

        let upgrade_cost = calculate_upgrade_cost(game.hero.upgrades_used);
        assert!(coin::value(&payment) >= upgrade_cost, EInsufficientFunds);

        coin::put(&mut pool.total_pool, payment);

        // Appliquer les améliorations
        let i = 0;
        while (i < vector::length(&stat_to_upgrade)) {
            let stat = *vector::borrow(&stat_to_upgrade, i);
            if (stat == 0) {
                game.hero.max_hp = game.hero.max_hp + 50;
                game.hero.hp = game.hero.max_hp; // Soigne complètement
            } else if (stat == 1) {
                game.hero.damage = game.hero.damage + 10;
            } else if (stat == 2) {
                game.hero.attack_speed = game.hero.attack_speed + 1;
            } else if (stat == 3) {
                if (game.hero.resistance < 75) { // Cap à 75%
                    game.hero.resistance = game.hero.resistance + 5;
                }
            };
            i = i + 1;
        };

        game.hero.upgrades_used = game.hero.upgrades_used + 1;

        event::emit(HeroUpgraded {
            player: game.player,
            stat_upgraded: stat_to_upgrade,
            new_stats: game.hero,
        });
    }

    /// Retirer les gains n'est plus nécessaire - paiement automatique
    // Cette fonction est supprimée car les gains sont payés automatiquement

    // === Helper Functions ===

    /// Génère des stats aléatoires pour le héros (faibles au début)
    fun generate_random_hero_stats(r: &Random, ctx: &mut TxContext): HeroStats {
        let mut gen = random::new_generator(r, ctx);
        
        // Stats plus faibles pour favoriser la maison
        let base_hp = 60 + (random::generate_u8_in_range(&mut gen, 0, 20) as u64);
        let damage = 10 + (random::generate_u8_in_range(&mut gen, 0, 10) as u64);
        let attack_speed = 1; // Fixe au début
        let resistance = random::generate_u8_in_range(&mut gen, 0, 5) as u64; // Très faible

        HeroStats {
            hp: base_hp,
            max_hp: base_hp,
            damage,
            attack_speed,
            resistance,
            upgrades_used: 0,
        }
    }

    /// Crée l'état d'un niveau
    fun create_level_state(level: u64, r: &Random, ctx: &mut TxContext): LevelState {
        let is_boss = (level % BOSS_LEVEL_INTERVAL == 0);
        let monster = generate_monster_for_level(level, is_boss, r, ctx);
        let monsters_count = if (is_boss) 1 else 3 + (level / 5);

        LevelState {
            current_level: level,
            monsters_remaining: monsters_count,
            current_monster: monster,
            is_boss_level: is_boss,
        }
    }

    /// Génère un monstre pour un niveau donné 
    fun generate_monster_for_level(
        level: u64, 
        is_boss: bool, 
        r: &Random, 
        ctx: &mut TxContext
    ): MonsterStats {
        let mut gen = random::new_generator(r, ctx);
        
        let base_multiplier = 100 + (level - 1) * MONSTER_SCALING_RATE;
        let boss_multiplier = if (is_boss) 400 else 100; // Boss 4x plus forts
        
        let hp = (BASE_MONSTER_HP * base_multiplier * boss_multiplier) / 10000;
        let damage = (BASE_MONSTER_DAMAGE * base_multiplier * boss_multiplier) / 10000;
        let reward = 0; // Pas de récompense immédiate

        MonsterStats {
            hp,
            max_hp: hp,
            damage,
            monster_type: if (is_boss) 1 else 0,
            reward,
        }
    }

    /// Simule un combat entre le héros et un monstre
    fun simulate_combat(
        hero: &HeroStats,
        monster: &MonsterStats,
        r: &Random,
        ctx: &mut TxContext
    ): (bool, u64) {
        let mut gen = random::new_generator(r, ctx);
        
        let mut hero_hp = hero.hp;
        let mut monster_hp = monster.hp;

        // Combat au tour par tour
        while (hero_hp > 0 && monster_hp > 0) {
            // Tour du héros (peut attaquer plusieurs fois selon attack_speed)
            let mut attacks = hero.attack_speed;
            while (attacks > 0 && monster_hp > 0) {
                let damage_dealt = hero.damage + random::generate_u8_in_range(&mut gen, 0, 10) as u64;
                if (monster_hp <= damage_dealt) {
                    monster_hp = 0;
                } else {
                    monster_hp = monster_hp - damage_dealt;
                };
                attacks = attacks - 1;
            };

            // Tour du monstre (si encore vivant)
            if (monster_hp > 0) {
                let damage_dealt = monster.damage;
                let damage_reduced = (damage_dealt * hero.resistance) / 100;
                let final_damage = if (damage_dealt > damage_reduced) {
                    damage_dealt - damage_reduced
                } else {
                    1 // Dégât minimum
                };

                if (hero_hp <= final_damage) {
                    hero_hp = 0;
                } else {
                    hero_hp = hero_hp - final_damage;
                }
            }
        };

        (monster_hp == 0, hero_hp)
    }

    /// Calcule le paiement final basé sur les niveaux complétés
    fun calculate_final_payout(bet_amount: u64, levels_completed: u64, house_edge: u64): (u64, u64) {
        if (levels_completed == 0) {
            return (0, bet_amount) // Maison garde tout
        };

        // Formule agressive : paiement = bet * (1 + levels/100)
        let base_multiplier = 1.0 + (levels_completed as f64 / 100.0); // 1% par niveau
        let gross_payout = bet_amount as f64 * base_multiplier;
        
        // Appliquer house edge (en pourcentage)
        let house_take = gross_payout * (house_edge as f64 / 100.0);
        
        // Gain net (jamais négatif)
        let net_payout = if gross_payout > house_take {
            gross_payout - house_take
        } else {
            0.0
        };

        // S'assurer que le paiement ne dépasse pas le bet * 1.5 max
        let max_payout = (bet_amount * 150) / 100;
        let final_payout = if (net_payout > max_payout) max_payout else net_payout;
        
        let house_profit = bet_amount - final_payout;
        
        (final_payout, house_profit)
    }

    /// Calcule le coût d'amélioration
    fun calculate_upgrade_cost(upgrades_used: u64): u64 {
        (upgrades_used + 1) * 100 // Coût croissant: 100, 200, 300, etc.
    }

    /// Passe au niveau suivant
    fun advance_to_next_level(
        game: &mut GameSession,
        r: &Random,
        ctx: &mut TxContext
    ) {
        game.level_state.monsters_remaining = game.level_state.monsters_remaining - 1;
        
        if (game.level_state.monsters_remaining == 0) {
            // Nouveau niveau
            let next_level = game.level_state.current_level + 1;
            game.level_state = create_level_state(next_level, r, ctx);
        } else {
            // Nouveau monstre du même niveau
            game.level_state.current_monster = generate_monster_for_level(
                game.level_state.current_level,
                game.level_state.is_boss_level,
                r,
                ctx
            );
        }
    }

    /// Termine le jeu avec paiement (succès)
    fun end_game_with_payout(
        game: &mut GameSession, 
        pool: &mut GamePool,
        ctx: &mut TxContext
    ): Coin<SUI> {
        game.game_active = false;
        
        let (payout, house_profit) = calculate_final_payout(
            game.bet_amount, 
            game.levels_completed, 
            pool.house_edge
        );

        event::emit(GameEnded {
            player: game.player,
            levels_completed: game.levels_completed,
            bet_amount: game.bet_amount,
            payout,
            house_profit,
        });

        if (payout > 0) {
            coin::take(&mut pool.total_pool, payout, ctx)
        } else {
            coin::zero(ctx)
        }
    }

    /// Termine le jeu quand le héros meurt (échec)
    fun end_game_hero_dead(
        game: &mut GameSession, 
        pool: &mut GamePool,
        ctx: &mut TxContext
    ) {
        game.game_active = false;

        event::emit(GameEnded {
            player: game.player,
            levels_completed: game.levels_completed,
            bet_amount: game.bet_amount,
            payout: 0,
            house_profit: game.bet_amount, // Maison garde tout
        });
    }

    // === Admin Functions ===

    /// Met à jour le house edge (admin seulement)
    public fun update_house_edge(
        _: &AdminCap,
        pool: &mut GamePool,
        new_edge: u64,
    ) {
        pool.house_edge = new_edge;
    }

    /// Retire les fonds du pool (admin seulement)
    public fun withdraw_from_pool(
        _: &AdminCap,
        pool: &mut GamePool,
        amount: u64,
        ctx: &mut TxContext
    ): Coin<SUI> {
        coin::take(&mut pool.total_pool, amount, ctx)
    }

    // === View Functions ===

    public fun get_hero_stats(game: &GameSession): &HeroStats {
        &game.hero
    }

    public fun get_level_state(game: &GameSession): &LevelState {
        &game.level_state
    }

    public fun get_game_info(game: &GameSession): (u64, u64, bool, u64) {
        (
            game.bet_amount,
            game.target_level,
            game.game_active,
            game.levels_completed
        )
    }
}
