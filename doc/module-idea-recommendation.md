# New Module Opportunity Review

## Purpose

This document captures the installed module landscape in this repository,
ecosystem research context, 5 practical new module ideas, and a final
recommendation for the best next module to build.

## Assumptions

- Modules present in `modules/` are treated as part of the project stack.
- Matching configs in `env/dist/etc/modules/` were used as a strong signal
  that a module is intended to be active or supported.
- `modules/Disabled/mod-anticheat` is treated as available but likely not
  currently enabled.

## Current Installed Modules / Major Capabilities

This project already has a very mature AzerothCore module stack.

### Solo / low-population support

- `mod-playerbots`
- `mod-autobalance`
- `mod-aoe-loot`
- `mod-individual-progression`
- `mod-weekend-xp`

### Custom endgame / challenge content

- `mod-mythic-plus`
- `mod-challenge-modes`
- `mod-instanced-worldbosses`
- `mod-city-siege`
- `mod-1v1-arena`
- `mod-arena-3v3-solo-queue`
- `Prestige`
- `mod-pvp-titles`

### Social / guild / economy systems

- `mod-globalchat`
- `mod-guildhouse`
- `mod-guild-village`
- `mod-ah-bot-plus`
- `mod-goblin-bank`
- `mod-transmog`
- `mod-account-achievements`

### API / automation / custom server features

- `mod-game-state-api`
- `mod-breaking-news-override`
- `mod-welcome-message`
- `mod-ptr-template`

### AI / assistant / scripting extensions

- `mod-oldman-assistant`
- `mod-ollama-chat`
- `mod-ale`

## High-Level Reading of This Stack

The server is already strong in:

- solo-friendly play,
- bot-assisted gameplay,
- custom progression,
- repeatable endgame activities,
- social/guild amenities,
- economy support,
- and custom server identity.

Because of that, the best new module opportunity is probably **not** another
isolated feature silo. The biggest opportunity is a module that improves
**discovery, activity flow, retention, and cross-module coordination**.

## Ecosystem Research Summary

Research into the AzerothCore ecosystem and adjacent custom-server patterns
suggested the following:

### Common module categories already covered here

Commonly available modules/plugins in this ecosystem include:

- account-wide collection systems,
- progression/reward systems,
- LFG/solo-friendly helpers,
- war-effort or server-event style content,
- economy and AH support,
- PvP queue variants,
- bot and quality-of-life utilities.

This project already covers many of those categories directly or indirectly.

### Likely gaps / unmet needs

What appears less common, and more valuable for this repository specifically:

- a **cross-module activity director**,
- better surfacing of "what should I do next?",
- stronger linking between seasonal/challenge/social systems,
- better re-use of the stack's existing content instead of adding more silos,
- and better guidance for solo players or players on low-pop servers.

### Opportunity area

The opportunity is to build a module that helps players move through the
server's existing ecosystem in a coherent loop, instead of leaving each system
disconnected and discoverable only by veteran players.

## New Module Ideas

## 1. `mod-adventure-board`

### Problem solved

Players on feature-rich servers often do not know what activities are worth
doing right now. Systems like Mythic+, Challenge Modes, world bosses, guild
content, PvP queues, prestige, and progression all exist, but they are not
presented as one clear journey.

### Target users

- new players,
- returning players,
- solo players,
- guilds looking for rotating shared goals,
- and admins who want better retention from existing features.

### Core features

- Daily and weekly activity board.
- Featured content slots driven by server state.
- Progression-aware recommendations.
- Optional rewards for completion streaks or category diversity.
- World announcements via existing server messaging modules.
- Optional API exposure through `mod-game-state-api`.

### Integration with installed modules

- `mod-mythic-plus`: recommend keystone goals or weekly dungeon targets.
- `mod-challenge-modes`: rotate featured challenge runs.
- `mod-instanced-worldbosses`: advertise active or upcoming boss windows.
- `mod-city-siege`: surface live city event participation.
- `Prestige`: attach prestige-oriented milestones.
- `mod-globalchat` / `mod-breaking-news-override`: promote featured content.
- `mod-playerbots`: optionally suggest bot-friendly activities.
- `mod-guild-village` / `mod-guildhouse`: support guild-focused board goals.

### Why it is differentiated

It does not duplicate your current systems. It makes them easier to discover,
use, and retain players around.

## 2. `mod-bot-party-director`

### Problem solved

Even with playerbots, group assembly and activity readiness can still feel
manual or inconsistent, especially for dungeon or event participation.

### Target users

- solo players,
- off-peak players,
- and admins running low- to mid-population realms.

### Core features

- smarter bot party assembly,
- role-balanced recommendations,
- dungeon/event readiness checks,
- activity-aware party suggestions,
- optional integration with queue or board systems.

### Integration with installed modules

- `mod-playerbots`
- `mod-autobalance`
- `mod-mythic-plus`
- `mod-challenge-modes`
- `mod-city-siege`

### Why it is differentiated

It focuses on solving the friction between having bots available and actually
turning them into usable content participation.

## 3. `mod-dynamic-warfronts`

### Problem solved

Many servers have events, but fewer have a reusable system for cyclical,
multi-zone faction conflict that evolves over time.

### Target users

- PvE/PvP hybrid players,
- guilds,
- and admins looking for server-wide seasonal content.

### Core features

- rotating warfront zones,
- contribution objectives,
- staged control changes,
- NPC/state changes per phase,
- weekly or seasonal reward tracks.

### Integration with installed modules

- `mod-city-siege`
- `mod-game-state-api`
- `mod-globalchat`
- `Prestige`
- `mod-pvp-titles`

### Why it is differentiated

It would create a reusable server event framework rather than a one-off event.
However, it is significantly heavier to design and maintain.

## 4. `mod-trade-contracts`

### Problem solved

Economy modules help supply the market, but players still benefit from a more
direct reason to gather, craft, deliver, or circulate goods.

### Target users

- economy-focused players,
- crafters,
- gatherers,
- guilds,
- and admins who want stronger market movement.

### Core features

- server-generated trade contracts,
- faction/city/guild delivery goals,
- rotating shortages/surpluses,
- contract rewards tied to reputation, prestige, or gold sinks.

### Integration with installed modules

- `mod-ah-bot-plus`
- `mod-goblin-bank`
- `mod-guild-village`
- `Prestige`

### Why it is differentiated

It gives the server economy more purpose beyond passive AH circulation.

## 5. `mod-collections-ledger`

### Problem solved

Account-wide achievement systems exist here, but collection identity could go
further with mounts, cosmetics, milestones, and curated progression display.

### Target users

- collectors,
- altoholics,
- long-term retention focused servers.

### Core features

- account-wide collection ledger,
- server-specific collectible categories,
- cosmetic milestone rewards,
- collection completion showcases,
- integration with prestige or seasonal systems.

### Integration with installed modules

- `mod-account-achievements`
- `mod-transmog`
- `Prestige`
- `mod-individual-progression`

### Why it is differentiated

It expands account identity and retention, but this area is more crowded in the
broader ecosystem than the cross-module orchestration opportunity.

## Final Recommendation

### Recommended module: `mod-adventure-board`

This is the strongest next module to build.

### Rationale

It is the best fit for this repository because:

1. **It leverages what already exists** rather than duplicating it.
2. **It improves player discovery and retention** across multiple systems.
3. **It is practical and feasible** compared with building an entirely new endgame mode.
4. **It benefits nearly every player segment**: solo, guild, returning, and endgame players.
5. **It compounds the value of your current stack** by turning many disconnected
   features into one coherent game loop.

### Best one-line pitch

Build `mod-adventure-board` as a server-wide activity director that turns the
current module stack into one coherent, replayable progression loop.

## Suggested Next Step

If this moves into implementation planning, the next document should define:

- MVP scope,
- data model,
- config keys,
- integration hooks,
- command/UI approach,
- and phased rollout.