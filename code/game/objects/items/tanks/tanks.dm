/obj/item/tank
	name = "tank"
	icon = 'icons/obj/tank.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/tanks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tanks_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	hitsound = 'sound/weapons/smash.ogg'
	pressure_resistance = ONE_ATMOSPHERE * 5
	force = 5
	throwforce = 10
	throw_speed = 1
	throw_range = 4
	custom_materials = list(/datum/material/iron = 500)
	actions_types = list(/datum/action/item_action/set_internals)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 30)
	var/datum/gas_mixture/air_contents = null
	var/distribute_pressure = ONE_ATMOSPHERE
	var/integrity = 3
	var/volume = 70

/obj/item/tank/ui_action_click(mob/user)
	toggle_internals(user)

/obj/item/tank/proc/toggle_internals(mob/user)
	var/mob/living/carbon/H = user
	if(!istype(H))
		return

	if(H.internal == src)
		to_chat(H, "<span class='notice'>You close [src] valve.</span>")
		H.internal = null
		H.update_internals_hud_icon(0)
	else
		if(!H.getorganslot(ORGAN_SLOT_BREATHING_TUBE))
			if(HAS_TRAIT(H, TRAIT_NO_INTERNALS))
				to_chat(H, "<span class='warning'>Due to cumbersome equipment or anatomy, you are currently unable to use internals!</span>")
				return
			var/obj/item/clothing/check
			var/internals = FALSE

			for(check in GET_INTERNAL_SLOTS(H))
				if(istype(check, /obj/item/clothing/mask))
					var/obj/item/clothing/mask/M = check
					if(M.mask_adjusted)
						M.adjustmask(H)
				if(CHECK_BITFIELD(check.clothing_flags, ALLOWINTERNALS))
					internals = TRUE

			if(!internals)
				to_chat(H, "<span class='warning'>You are not wearing an internals mask!</span>")
				return

		if(H.internal)
			to_chat(H, "<span class='notice'>You switch your internals to [src].</span>")
		else
			to_chat(H, "<span class='notice'>You open [src] valve.</span>")
		H.internal = src
		H.update_internals_hud_icon(1)
	H.update_action_buttons_icon()


/obj/item/tank/Initialize()
	. = ..()

	air_contents = new(volume) //liters
	air_contents.set_temperature(T20C)

	populate_gas()

	START_PROCESSING(SSobj, src)

/obj/item/tank/proc/populate_gas()
	return

/obj/item/tank/Destroy()
	if(air_contents)
		qdel(air_contents)

	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/tank/examine(mob/user)
	var/obj/icon = src
	. = ..()
	if(istype(src.loc, /obj/item/assembly))
		icon = src.loc
	if(!in_range(src, user) && !isobserver(user))
		if (icon == src)
			. += "<span class='notice'>If you want any more information you'll need to get closer.</span>"
		return

	. += "<span class='notice'>The pressure gauge reads [round(src.air_contents.return_pressure(),0.01)] kPa.</span>"

	var/celsius_temperature = src.air_contents.return_temperature()-T0C
	var/descriptive

	if (celsius_temperature < 20)
		descriptive = "cold"
	else if (celsius_temperature < 40)
		descriptive = "room temperature"
	else if (celsius_temperature < 80)
		descriptive = "lukewarm"
	else if (celsius_temperature < 100)
		descriptive = "warm"
	else if (celsius_temperature < 300)
		descriptive = "hot"
	else
		descriptive = "furiously hot"

	. += "<span class='notice'>It feels [descriptive].</span>"

/obj/item/tank/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc)
		var/turf/location = get_turf(src)
		if(!location)
			qdel(src)

		if(air_contents)
			location.assume_air(air_contents)

		qdel(src)

/obj/item/tank/analyzer_act(mob/living/user, obj/item/I)
	atmosanalyzer_scan(air_contents, user, src)
	return TRUE

/obj/item/tank/deconstruct(disassembled = TRUE)
	if(!disassembled)
		var/turf/T = get_turf(src)
		if(T)
			T.assume_air(air_contents)
			air_update_turf()
		playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
	qdel(src)

/obj/item/tank/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	user.visible_message("<span class='suicide'>[user] is putting [src]'s valve to [user.p_their()] lips! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/effects/spray.ogg', 10, 1, -3)
	if (!QDELETED(H) && air_contents && air_contents.return_pressure() >= 1000)
		for(var/obj/item/W in H)
			H.dropItemToGround(W)
			if(prob(50))
				step(W, pick(GLOB.alldirs))
		ADD_TRAIT(H, TRAIT_DISFIGURED, TRAIT_GENERIC)
		H.gib_animation()
		sleep(3)
		H.adjustBruteLoss(1000) //to make the body super-bloody
		H.spawn_gibs()
		H.spill_organs()
		H.spread_bodyparts()

	return (BRUTELOSS)

/obj/item/tank/attack_ghost(mob/dead/observer/O)
	. = ..()
	atmosanalyzer_scan(air_contents, O, src, FALSE)

/obj/item/tank/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/assembly_holder))
		bomb_assemble(W,user)
	else
		. = ..()

/obj/item/tank/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/tank/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Tank", name)
		ui.open()

/obj/item/tank/ui_data(mob/user)
	var/list/data = list()
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(distribute_pressure ? distribute_pressure : 0)
	data["defaultReleasePressure"] = round(TANK_DEFAULT_RELEASE_PRESSURE)
	data["minReleasePressure"] = round(TANK_MIN_RELEASE_PRESSURE)
	data["maxReleasePressure"] = round(TANK_MAX_RELEASE_PRESSURE)

	var/mob/living/carbon/C = user
	if(!istype(C))
		C = loc.loc
	if(!istype(C))
		return data

	if(C.internal == src)
		data["connected"] = TRUE

	return data

/obj/item/tank/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = initial(distribute_pressure)
				. = TRUE
			else if(pressure == "min")
				pressure = TANK_MIN_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "max")
				pressure = TANK_MAX_RELEASE_PRESSURE
				. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				distribute_pressure = clamp(round(pressure), TANK_MIN_RELEASE_PRESSURE, TANK_MAX_RELEASE_PRESSURE)

/obj/item/tank/remove_air(amount)
	return air_contents.remove(amount)

/obj/item/tank/remove_air_ratio(ratio)
	return air_contents.remove_ratio(ratio)

/obj/item/tank/return_air()
	return air_contents

/obj/item/tank/assume_air(datum/gas_mixture/giver)
	air_contents.merge(giver)

	check_status()
	return 1

/obj/item/tank/assume_air_moles(datum/gas_mixture/giver, moles)
	giver.transfer_to(air_contents, moles)

	check_status()
	return 1

/obj/item/tank/assume_air_ratio(datum/gas_mixture/giver, ratio)
	giver.transfer_ratio_to(air_contents, ratio)

	check_status()
	return 1

/obj/item/tank/proc/remove_air_volume(volume_to_return)
	if(!air_contents)
		return null

	var/tank_pressure = air_contents.return_pressure()
	if(tank_pressure < distribute_pressure)
		distribute_pressure = tank_pressure

	var/moles_needed = distribute_pressure*volume_to_return/(R_IDEAL_GAS_EQUATION*air_contents.return_temperature())

	return remove_air(moles_needed)

/obj/item/tank/process()
	//Allow for reactions
	air_contents.react()
	check_status()

/obj/item/tank/proc/check_status()
	//Handle exploding, leaking, and rupturing of the tank

	if(!air_contents)
		return 0

	var/pressure = air_contents.return_pressure()
	var/temperature = air_contents.return_temperature()

	if(pressure > TANK_FRAGMENT_PRESSURE)
		if(!istype(src.loc, /obj/item/transfer_valve))
			message_admins("Explosive tank rupture! Last key to touch the tank was [src.fingerprintslast].")
			log_game("Explosive tank rupture! Last key to touch the tank was [src.fingerprintslast].")
		//Give the gas a chance to build up more pressure through reacting
		air_contents.react(src)
		air_contents.react(src)
		//Citadel Edit: removing extra react for "balance"
		pressure = air_contents.return_pressure()
		var/range = (pressure-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE
		var/turf/epicenter = get_turf(loc)


		explosion(epicenter, round(range*0.25), round(range*0.5), round(range), round(range*1.5))
		if(istype(src.loc, /obj/item/transfer_valve))
			qdel(src.loc)
		else
			qdel(src)

	else if(pressure > TANK_RUPTURE_PRESSURE || temperature > TANK_MELT_TEMPERATURE)
		if(integrity <= 0)
			var/turf/T = get_turf(src)
			if(!T)
				return
			T.assume_air(air_contents)
			playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
			qdel(src)
		else
			integrity--

	else if(pressure > TANK_LEAK_PRESSURE)
		if(integrity <= 0)
			var/turf/T = get_turf(src)
			if(!T)
				return
			var/datum/gas_mixture/leaked_gas = air_contents.remove_ratio(0.25)
			T.assume_air(leaked_gas)
		else
			integrity--

	else if(integrity < 3)
		integrity++
