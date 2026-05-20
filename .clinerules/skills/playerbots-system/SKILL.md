---
name: playerbots-system
description: Work with the mod-playerbots system. Use when modifying bot behavior, adding bot features, debugging bot PvP/raids/auction/trading, or investigating bot crashes.
---

# Skill: playerbots-system

**Owner:** Old Man Warcraft
**Version:** 1.0

## Purpose

Reference for the Playerbots system — AI-driven player bots that emulate real
players in AzerothCore. Located in `modules/playerbots/`.

## Architecture

| Component | Purpose |
|---|---|
| `PlayerbotAI` | Core AI logic — decision making, strategy selection |
| `PlayerbotMgr` | Bot lifecycle management, world interaction |
| `PlayerbotFactory` | Bot creation, initialization, gearing |
| `Strategy` | Behavior tree-like action selection |
| `Action` | Individual bot actions (cast, move, use item, etc.) |
| `Trigger` | Conditions that activate strategies |
| `Value` | Bot knowledge/state caching |

## Key directories

```
modules/playerbots/
├── src/
│   ├── PlayerbotAI.cpp/h         — Core AI
│   ├── PlayerbotMgr.cpp/h        — Manager
│   ├── PlayerbotFactory.cpp/h    — Factory
│   ├── strategy/                 — Strategy/Action/Trigger definitions
│   │   ├── actions/             — Combat, movement, trade, chat actions
│   │   ├── triggers/            — Health, mana, cooldown triggers
│   │   ├── values/              — Cached bot state values
│   │   └── Strategy.cpp/h       — Strategy base
│   ├── RandomPlayerbotMgr.cpp/h  — Random bot management
│   ├── RandomPlayerbotFactory.cpp/h — Random bot factory
│   └── TravelMgr.cpp/h          — Travel/pathing
├── conf/
│   └── playerbots.conf.dist      — Default config
├── data/sql/                     — SQL updates
└── CMakeLists.txt
```

## Configuration

Key `playerbots.conf` options:

| Option | Default | Description |
|---|---|---|
| `Playerbots.Enabled` | 1 | Enable/disable playerbots |
| `Playerbots.RandomBotAutologin` | 0 | Auto-login random bots on start |
| `Playerbots.RandomBotCount` | 50 | Number of random bots |
| `Playerbots.MinRandomBots` | 50 | Minimum random bots |
| `Playerbots.MaxRandomBots` | 200 | Maximum random bots |
| `Playerbots.RandomBotMinLevel` | 1 | Min random bot level |
| `Playerbots.RandomBotMaxLevel` | 80 | Max random bot level |
| `Playerbots.RandomBotLoginInterval` | 5 | Seconds between random bot logins |
| `Playerbots.Debug` | 0 | Enable debug logging |
| `Playerbots.LootAward` | 1 | Allow bots to receive loot |

## Strategy system

Strategies are organized in a priority-based tree:

```
Combat Strategy (highest priority in combat)
├── Tank Strategy
├── Heal Strategy
├── DPS Strategy
├── Crowd Control Strategy
└── Movement Strategy

Non-Combat Strategy
├── Quest Strategy
├── Grind Strategy
├── Travel Strategy
├── Trade Strategy
├── Guild Strategy
└── Social Strategy
```

### Adding a new strategy

```cpp
// 1. Define strategy class
class MyCustomStrategy : public Strategy
{
public:
    MyCustomStrategy(PlayerbotAI* ai) : Strategy(ai) {}

    string getName() override { return "my custom"; }

    void InitTriggers(std::list<TriggerNode*>& triggers) override
    {
        triggers.push_back(new TriggerNode(
            "my trigger condition",
            NextAction::array(0, new NextAction("my action", relevance), NULL)));
    }
};

// 2. Register in strategy loader
ai->AddStrategy(new MyCustomStrategy(ai));
```

### Adding a new action

```cpp
class MyCustomAction : public Action
{
public:
    MyCustomAction(PlayerbotAI* ai) : Action(ai, "my action") {}

    bool Execute(Event event) override
    {
        // Your action logic
        return true; // true = action consumed
    }

    bool isPossible() override
    {
        // Check if action can be executed
        return true;
    }
};
```

## Safety rules

**Always invoke `playerbots-safety-reviewer` agent when modifying playerbots code.**

1. **Null checks** — Every pointer dereference must be null-checked
2. **Thread safety** — Use `Player::Schedule` for off-thread operations
3. **Group limits** — Enforce party (5) and raid (40) size caps
4. **Economy** — No infinite gold/item generation
5. **Arena** — Respect bracket requirements and rating calculations
6. **Guild** — Verify permission checks for guild operations

## Common operations

### Create a bot
```cpp
PlayerbotFactory factory(player, level, class, race);
factory.Clean();
factory.InitEquipment();
factory.InitSkills();
factory.InitTalents();
factory.InitGlyphs();
factory.Refresh();
```

### Make bot join group
```cpp
WorldPacket packet(CMSG_GROUP_INVITE);
packet << bot->GetName();
master->GetSession()->HandleGroupInvite(packet);
```

### Bot combat behavior
```cpp
// Bots use strategy system for combat
// Strategies are checked in priority order
// Highest priority matching strategy executes its actions
```

## Debugging

```cpp
// Enable debug output
if (sPlayerbotConfig->debug)
{
    TC_LOG_INFO("playerbots", "Bot {} ({}) executing action: {}",
        bot->GetName(), bot->GetGUID().ToString(), action->getName());
}
```

## Known pitfalls

1. **Stuck detection** — Bots can get stuck on terrain; use movement timeout and recalculation
2. **Spell queue overflow** — Limit concurrent spell casts per bot
3. **Memory leaks** — Strategy/Action objects must be properly cleaned up on logout
4. **Database race** — Bot saves should be batched, not per-action
5. **AH/mail spam** — Rate-limit bot economic activities