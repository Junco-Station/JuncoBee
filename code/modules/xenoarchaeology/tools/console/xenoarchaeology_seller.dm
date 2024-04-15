/*
	Seller personality for the RND listing console
*/

#define SELLER_PERSONALITY_GENEROUS "SELLER_PERSONALITY_GENEROUS"
#define SELLER_PERSONALITY_NORMAL "SELLER_PERSONALITY_NORMAL"
#define SELLER_PERSONALITY_STINGY "SELLER_PERSONALITY_STINGY"
#define SELLER_PERSONALITY_SCARED "SELLER_PERSONALITY_SCARED"

//Move this to its own datum file if you implement it for other sub departments of science
/datum/rnd_lister
	///What is this slimeball's name
	var/name = "Petrikov"
	///What nonsense flavor dialogue do they spout
	var/dialogue = ""
	///What kind of selling personality do they have
	var/personality = SELLER_PERSONALITY_GENEROUS
	///How often do they restock their... stock
	var/restock_time = 1 MINUTES
	///What science thingy are they selling
	var/atom/stock_type
	var/list/current_stock = list()
	var/max_stock = 1

/datum/rnd_lister/New()
	. = ..()
	//Generate initial stock
	replenish_stock(max_stock)

//Generic random seller
/datum/rnd_lister/random/New()
	. = ..()
	///Randomized stats
	name = pick(GLOB.xenoa_seller_names)
	dialogue = pick(GLOB.xenoa_seller_dialogue)
	personality = pick(list(SELLER_PERSONALITY_GENEROUS, SELLER_PERSONALITY_NORMAL, SELLER_PERSONALITY_STINGY))

/datum/rnd_lister/proc/get_new_stock()
	return new stock_type()

///Get the price of an atom, persumably our stock, based on our selling personality
/datum/rnd_lister/proc/get_price(atom/A)
	switch(personality)
		if(SELLER_PERSONALITY_GENEROUS)
			return A.custom_price * 0.8
		if(SELLER_PERSONALITY_NORMAL)
			return A.custom_price
		if(SELLER_PERSONALITY_STINGY)
			return A.custom_price * 1.5
		else
			return 0 //FOR FREE!

/datum/rnd_lister/proc/buy_stock(atom/A)
	//Remove stock and prepare to replace it
	current_stock -= A
	addtimer(CALLBACK(src, PROC_REF(replenish_stock)), restock_time)
	return A

/datum/rnd_lister/proc/replenish_stock(amount = 1)
	for(var/i in 1 to amount)
		var/atom/A = get_new_stock()
		current_stock += A

/*
	Artifact sellers
*/

/datum/rnd_lister/artifact_seller
	///What kind of artifacts do we sell - Weighted list
	var/list/artifact_types = list(XENOA_BLUESPACE = 1, XENOA_PLASMA = 1, XENOA_URANIUM = 1, XENOA_BANANIUM = 1)

/datum/rnd_lister/artifact_seller/get_new_stock()
	var/datum/xenoartifact_material/M = pick_weight(artifact_types)
	var/obj/item/xenoartifact/artifact = new(null, M)
	return artifact

/*
	Actual types of artifact sellers
*/

//Will sell random artifacts equally, but at a stingy price
/datum/rnd_lister/artifact_seller/bastard
	name = "Sidorovich"
	dialogue = "What are you standing there for? come closer."
	personality = SELLER_PERSONALITY_STINGY

/*
	Supply pack for this system
	Whenever a listing is purchased, a supply pack with the purchased items is returned
*/
/datum/supply_pack/science_listing
	name = "Research Material Listing"
	desc = "Contains potentially hazardous materials, or ridiculous ties."
	hidden = TRUE
	crate_name = "research material container"
	crate_type = /obj/structure/closet/crate/science
	access_any = TRUE
	max_supply = 1
	current_supply = 1
	can_secure = FALSE

#undef SELLER_PERSONALITY_GENEROUS
#undef SELLER_PERSONALITY_NORMAL
#undef SELLER_PERSONALITY_STINGY
#undef SELLER_PERSONALITY_SCARED
