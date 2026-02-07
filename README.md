# rtv-arcade (RTV Scripts)

Arcade machines for QB/Qbx using **ox_target** + **ox_lib**, with **generic minigame support** (not tied to any single minigame resource).

Players can:
1. Pay an entry fee (cash/bank)
2. Play a minigame
3. On win: receive **arcade tickets**
4. Exchange tickets at the **Prize Counter** for items

Targets are **boxzones by coordinates** — meaning each machine is bound to a specific location, not a prop model.

---

## Dependencies

Required:
- `ox_lib`
- `ox_target`

Recommended:
- `ox_inventory` (to store tickets cleanly)

Optional:
- Any minigame resource that provides:
  - exports that return `true/false`, OR
  - exports that use a callback, OR
  - events (start + result event)

---

## Installation

1) Put `rtv-arcade` into your resources folder:

2) Ensure dependencies start before it:

ensure ox_lib
ensure ox_target
ensure qb-core
ensure ox_inventory
ensure rtv-arcade

## ox_inventory: Arcade Ticket Item:
['arcade_ticket'] = {
    label = 'RTV Arcade Ticket',
    weight = 0,
    stack = true,
    close = false,
    description = 'Arcade ticket from RTV Scripts. Exchange at the Prize Counter.',
    client = {
        image = 'arcade_ticket.png',
    }
},

## Add an icon file:
- ox_inventory/web/images/arcade_ticket.png
Restart ox_inventory and then restart your server/resource.

## Machines (boxzone based)

Each machine needs:
- coords = vec4(x,y,z,heading)
- zoneSize = vec3(width, length, height)
- entry fee + account
- reward range
- Minigame configuration (optional — if omitted, fallback skillcheck is used)
Example:

- TGG-minigames
[1] = {
  label = 'Masher',
  coords = vec4(-1652.10, -1077.20, 13.15, 150.0),
  zoneSize = vec3(0.8, 0.8, 1.2),
  entryFee = 200,
  account = 'cash',
  reward = { minTickets = 3, maxTickets = 6 },
  Minigame = { ... }
}

- Generic (ps-ui)
Minigame = {
  type = 'export',
  resource = 'my-callback-minigame',
  export = 'StartGame',
  style = 'callback',
  args = { 'medium', 30 } -- array args => passed as varargs after callback
}
- Event based
Minigame = {
  type = 'event',
  startEvent = 'somegame:client:start',
  resultEvent = 'somegame:client:result',
  timeout = 60,
  args = { difficulty = 'hard' }
}

# RTV Scripts

# Tag: rtv
# GitHub: RuubTv
