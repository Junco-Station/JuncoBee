//Nuclear particle projectile - a deadly side effect of fusion
/obj/projectile/energy/nuclear_particle
	name = "nuclear particle"
	icon_state = "nuclear_particle"
	pass_flags = PASSTABLE | PASSTRANSPARENT | PASSGRILLE
	damage = 10
	damage_type = TOX
	irradiate = 2500 //enough to knockdown and induce vomiting
	speed = 0.4
	hitsound = 'sound/weapons/emitter2.ogg'
	impact_type = /obj/effect/projectile/impact/xray
	var/static/list/particle_colors = list(
		"red" = "#FF0000",
		"blue" = "#00FF00",
		"green" = "#0000FF",
		"yellow" = "#FFFF00",
		"cyan" = "#00FFFF",
		"purple" = "#FF00FF"
	)

/obj/projectile/energy/nuclear_particle/proc/random_color_time()
	//Random color time!
	var/our_color = pick(particle_colors)
	add_atom_colour(particle_colors[our_color], FIXED_COLOUR_PRIORITY)
	set_light(4, 3, particle_colors[our_color]) //Range of 4, brightness of 3 - Same range as a flashlight

/obj/projectile/energy/nuclear_particle/proc/customize(custompower)
	irradiate = max(3000 * 3 ** (log(10,custompower)-FUSION_RAD_MIDPOINT),10)
	var/custom_color = HSVtoRGB(hsv(clamp(log(10,custompower)-12,0,5)*256,rand(191,255),rand(191,255),255))
	add_atom_colour(custom_color, FIXED_COLOUR_PRIORITY)
	set_light(4, 3, custom_color)
	switch (irradiate)
		if(10 to 100)
			name = "pathetically weak nuclear particle"
			damage = 1
		if(100 to 200)
			name = "very weak nuclear particle"
			damage = 2
		if(200 to 500)
			name = "fairly weak nuclear particle"
			damage = 4
		if(500 to 1500)
			name = "slightly weak nuclear particle"
			damage = 7
		if(4000 to 8000)
			name = "powerful nuclear particle"
			damage = 15
		if(8000 to 30000)
			name = "extremely strong nuclear particle"
			damage = 20
		if(30000 to INFINITY)
			name = "impossibly strong nuclear particle"
			damage = 30

//TODO: Consider adding an atmos requirement - Racc : CONSULT, PLAYTEST
/obj/projectile/energy/nuclear_particle/scan_moved_turf()
	. = ..()
	//Do a gas check first
	var/turf/T = get_turf(src)
	var/datum/gas_mixture/air = T?.return_air()
	if((air?.get_moles(GAS_TRITIUM) < MOLES_GAS_VISIBLE))
		return
	for(var/obj/item/I in loc)
		//TODO: Consider using some fancy math here, or something - Racc : CONSULT, PLAYTEST
		if(!prob(33))
			continue
		//Proceed with artifact logic
		var/datum/component/xenoartifact/X = I.GetComponent(/datum/component/xenoartifact)
		if(X)
			continue
		//Check for any pearls attached to the item first
		var/trait_list = list()
		for(var/obj/item/sticker/trait_pearl/P in I.contents)
			trait_list += P.stored_trait
			qdel(P)
		//Make the item an artifact
		I.AddComponent(/datum/component/xenoartifact, /datum/xenoartifact_material/pearl, length(trait_list) ? trait_list : null, TRUE, FALSE)
		playsound(I, 'sound/magic/staff_change.ogg', 50, TRUE)
		qdel(src)
		break

/atom/proc/fire_nuclear_particle(angle = rand(0,360), customize = FALSE, custompower = 1e12) //used by fusion to fire random nuclear particles. Fires one particle in a random direction.
	var/obj/projectile/energy/nuclear_particle/P = new /obj/projectile/energy/nuclear_particle(src)
	if(customize)
		P.customize(custompower)
	else
		P.random_color_time()
	P.fire(angle)
