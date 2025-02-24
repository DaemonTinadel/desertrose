// Chili
/obj/item/seeds/chili
	name = "pack of chili seeds"
	desc = "These seeds grow into chili plants. HOT! HOT! HOT!"
	icon_state = "seed-chili"
	species = "chili"
	plantname = "Chili Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/chili
	lifespan = 20
	maturation = 5
	production = 5
	yield = 4
	potency = 20
	instability = 30
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "chili-grow" // Uses one growth icons set for all the subtypes
	icon_dead = "chili-dead" // Same for the dead icon
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/chili/ice, /obj/item/seeds/chili/ghost, /obj/item/seeds/chili/bell_pepper)
	reagents_add = list(/datum/reagent/consumable/capsaicin = 0.25, /datum/reagent/consumable/nutriment/vitamin = 0.04, /datum/reagent/consumable/nutriment = 0.04)

/obj/item/reagent_containers/food/snacks/grown/chili
	seed = /obj/item/seeds/chili
	name = "chili"
	desc = "It's spicy! Wait... IT'S BURNING ME!!"
	icon_state = "chilipepper"
	filling_color = "#FF0000"
	bitesize_mod = 2
	foodtype = FRUIT
	wine_power = 20

// Ice Chili
/obj/item/seeds/chili/ice
	name = "pack of ice pepper seeds"
	desc = "These seeds grow into ice pepper plants."
	icon_state = "seed-icepepper"
	species = "chiliice"
	plantname = "Ice Pepper Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/icepepper
	lifespan = 25
	maturation = 4
	production = 4
	rarity = 20
	mutatelist = list()
	reagents_add = list(/datum/reagent/consumable/frostoil = 0.25, /datum/reagent/consumable/nutriment/vitamin = 0.02, /datum/reagent/consumable/nutriment = 0.02)

/obj/item/reagent_containers/food/snacks/grown/icepepper
	seed = /obj/item/seeds/chili/ice
	name = "ice pepper"
	desc = "It's a mutant strain of chili."
	icon_state = "icepepper"
	filling_color = "#0000CD"
	bitesize_mod = 2
	foodtype = FRUIT
	wine_power = 30

// Ghost Chili
/obj/item/seeds/chili/ghost
	name = "pack of ghost chili seeds"
	desc = "These seeds grow into a chili said to be the hottest in the galaxy."
	icon_state = "seed-chilighost"
	species = "chilighost"
	plantname = "Ghost Chili Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/ghost_chili
	endurance = 10
	maturation = 10
	production = 10
	yield = 3
	rarity = 20
	mutatelist = list()
	reagents_add = list(/datum/reagent/consumable/condensedcapsaicin = 0.3, /datum/reagent/consumable/capsaicin = 0.55, /datum/reagent/consumable/nutriment = 0.04)

/obj/item/reagent_containers/food/snacks/grown/ghost_chili
	seed = /obj/item/seeds/chili/ghost
	name = "ghost chili"
	desc = "It seems to be vibrating gently."
	icon_state = "ghostchilipepper"
	var/mob/living/carbon/human/held_mob
	filling_color = "#F8F8FF"
	bitesize_mod = 4
	foodtype = FRUIT
	wine_power = 50

/obj/item/reagent_containers/food/snacks/grown/ghost_chili/on_attack_hand(mob/user, act_intent = user.a_intent, unarmed_attack_flags)
	. = ..()
	if(ishuman(loc))
		held_mob = loc
		START_PROCESSING(SSobj, src)

/obj/item/reagent_containers/food/snacks/grown/ghost_chili/process()
	if(held_mob && loc == held_mob)
		if(held_mob.is_holding(src))
			if(istype(held_mob) && held_mob.gloves)
				return
			held_mob.adjust_bodytemperature(15 * TEMPERATURE_DAMAGE_COEFFICIENT)
			if(prob(10))
				to_chat(held_mob, "<span class='warning'>Your hand holding [src] burns!</span>")
	else
		held_mob = null
		..()

// Bell Pepper
/obj/item/seeds/chili/bell_pepper
	name = "pack of bell pepper seeds"
	desc = "These seeds grow into bell pepper plants. MILD! MILD! MILD!"
	icon_state = "seed-bell-pepper"
	species = "bellpepper"
	plantname = "Bell Pepper Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/bell_pepper
	endurance = 10
	maturation = 10
	production = 10
	yield = 3
	rarity = 20
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = null
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.08, /datum/reagent/consumable/nutriment = 0.04)

/obj/item/reagent_containers/food/snacks/grown/bell_pepper
	seed = /obj/item/seeds/chili/bell_pepper
	name = "bell pepper"
	desc = "A big mild pepper that's good for many things."
	icon_state = "bell_pepper"
	foodtype = FRUIT
	
/obj/item/reagent_containers/food/snacks/grown/bell_pepper/microwave_act(obj/machinery/microwave/M)
	new /obj/item/reagent_containers/food/snacks/roasted_bell_pepper(drop_location(), 1)
	qdel(src)
