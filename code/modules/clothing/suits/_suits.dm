#define FOOTSTEP_COOLDOWN 3	//3 deci-seconds

/obj/item/clothing/suit
	name = "suit"
	icon = 'icons/obj/clothing/suits/default.dmi'
	var/fire_resist = T0C+100
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound =  'sound/items/handling/cloth_pickup.ogg'
	allowed = list(
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman
	)
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 0, BLEED = 5)
	slot_flags = ITEM_SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	var/move_sound = null
	var/footstep = 0
	var/mob/listeningTo
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/exo

/obj/item/clothing/suit/Initialize(mapload)
	. = ..()
	setup_shielding()

/obj/item/clothing/suit/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, item_layer, atom/origin)
	. = list()
	if(!isinhands)
		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damageduniform", item_layer)
		if(HAS_BLOOD_DNA(src))
			var/mutable_appearance/bloody_armor = mutable_appearance('icons/effects/blood.dmi', "[blood_overlay_type]blood", item_layer)
			bloody_armor.color = get_blood_dna_color(return_blood_DNA())
			. += bloody_armor
		var/mob/living/carbon/human/M = loc
		if(ishuman(M) && M.w_uniform)
			var/obj/item/clothing/under/U = M.w_uniform
			if(istype(U) && U.attached_accessory)
				var/obj/item/clothing/accessory/A = U.attached_accessory
				if(A.above_suit)
					. += U.accessory_overlay

/obj/item/clothing/suit/update_clothes_damaged_state(damaged_state = CLOTHING_DAMAGED)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_wear_suit()

/obj/item/clothing/suit/proc/on_mob_move()
	SIGNAL_HANDLER

	var/mob/living/carbon/human/H = loc
	if(!istype(H) || H.wear_suit != src)
		return
	if(world.time > footstep)
		playsound(src, pick(move_sound), 65, 1)
		footstep = world.time + FOOTSTEP_COOLDOWN

/obj/item/clothing/suit/equipped(mob/user, slot)
	. = ..()
	//If we dont have move sounds, ignore
	if(!islist(move_sound))
		return
	//Check if we were taken off.
	if(slot != ITEM_SLOT_OCLOTHING)
		if(listeningTo)
			UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
			listeningTo = null
		return
	if(listeningTo == user)
		return
	//Remove old listener
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	//Add new listener
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_mob_move))
	listeningTo = user

/obj/item/clothing/suit/dropped(mob/user)
	..()
	//Remove our listener
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null

/obj/item/clothing/suit/Destroy()
	listeningTo = null
	. = ..()

/**
 * Wrapper proc to apply shielding through AddComponent().
 * Called in /obj/item/clothing/Initialize().
 * Override with an AddComponent(/datum/component/shielded, args) call containing the desired shield statistics.
 * See /datum/component/shielded documentation for a description of the arguments
 **/
/obj/item/clothing/suit/proc/setup_shielding()
	return

#undef FOOTSTEP_COOLDOWN
