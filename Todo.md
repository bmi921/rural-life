# Stardew Valley-like Features Plan

## 1. Inventory System (Items & UI)
- [ ] Create `Item` resource class (name, icon, type, value).
- [ ] Create `Inventory` resource class (holds array of Items).
- [ ] Create UI Scene `InventoryUI.tscn` (grid of slots).
- [ ] Add `InventoryUI` to `Main2D` scene under `CanvasLayer`.
- [ ] Implement toggle logic (press 'I' to open/close).

## 2. Weapon System (Simple Attack)
- [ ] Add `Weapon` resource type (damage, range, cooldown).
- [ ] Update `Player.gd` to handle "attack" state.
- [ ] Add `Hitbox` Area2D to Player to detect hits.
- [ ] Implement "Attack" animation (simple sprite swing or rotation).
- [ ] Add `Enemy` or `BreakableObject` to test damage.

## 3. Terrain Generation Upgrade
- [ ] Enhance `ground_generator.gd` to include:
    - Water tiles (lakes/rivers).
    - Trees (static bodies with collision).
    - Rocks (breakable objects).
- [ ] Use `FastNoiseLite` for more natural distribution.

## 4. House Implementation
- [ ] Create `House.tscn` (Sprite + Collision + Door Area).
- [ ] Create `Interior.tscn` (Scene for inside the house).
- [ ] Implement teleport/transition logic when entering the door.
- [ ] Place House in the generated world (fixed location or procedural).

## 5. Game Loop & Interaction
- [ ] Add `InteractionArea` to Player (to pick up items, open doors).
- [ ] Add "Day/Night" cycle (simple overlay or light modulation).
