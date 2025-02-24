//IN THIS DOCUMENT: Rifle template, Lever-action rifles, Bolt-action rifles, Magazine-fed bolt-action rifles

////////////////////
// RIFLE TEMPLATE //
////////////////////

/obj/item/gun/ballistic/rifle

	name = "rifle template"
	desc = "Should not exist"
	icon = 'icons/obj/guns/projectile.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	icon_state = "shotgun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	can_automatic = FALSE
	slowdown = 0.5
	fire_delay = 6
	spread = 0
	force = 15 //Decent clubs generally speaking
	flags_1 =  CONDUCT_1
	casing_ejector = FALSE
	var/recentpump = 0 // to prevent spammage
	spawnwithmagazine = TRUE
	var/pump_sound = 'sound/weapons/shotgunpump.ogg'
	fire_sound = 'sound/f13weapons/shotgun.ogg'

/obj/item/gun/ballistic/rifle/process_chamber(mob/living/user, empty_chamber = 0)
	return ..() //changed argument value

/obj/item/gun/ballistic/rifle/can_shoot()
	return !!chambered?.BB

/obj/item/gun/ballistic/rifle/attack_self(mob/living/user)
	if(recentpump > world.time)
		return
	if(IS_STAMCRIT(user))//CIT CHANGE - makes pumping shotguns impossible in stamina softcrit
		to_chat(user, "<span class='warning'>You're too exhausted for that.</span>")//CIT CHANGE - ditto
		return//CIT CHANGE - ditto
	pump(user, TRUE)
	if(HAS_TRAIT(user, TRAIT_FAST_PUMP))
		recentpump = world.time + 2
	else
		recentpump = world.time + 10
		if(istype(user))//CIT CHANGE - makes pumping shotguns cost a lil bit of stamina.
			user.adjustStaminaLossBuffered(2) //CIT CHANGE - DITTO. make this scale inversely to the strength stat when stats/skills are added
	return

/obj/item/gun/ballistic/rifle/blow_up(mob/user)
	. = 0
	if(chambered && chambered.BB)
		process_fire(user, user, FALSE)
		. = 1

/obj/item/gun/ballistic/rifle/proc/pump(mob/M, visible = TRUE)
	if(visible)
		M.visible_message("<span class='warning'>[M] racks [src].</span>", "<span class='warning'>You rack [src].</span>")
	playsound(M, pump_sound, 60, 1)
	pump_unload(M)
	pump_reload(M)
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/gun/ballistic/rifle/proc/pump_unload(mob/M)
	if(chambered)//We have a shell in the chamber
		chambered.forceMove(drop_location())//Eject casing
		chambered.bounce_away()
		chambered = null

/obj/item/gun/ballistic/rifle/proc/pump_reload(mob/M)
	if(!magazine || !magazine.ammo_count())
		return 0
	var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
	chambered = AC

/obj/item/gun/ballistic/rifle/examine(mob/user)
	. = ..()
	if (chambered)
		. += "A [chambered.BB ? "live" : "spent"] one is in the chamber."

/obj/item/gun/ballistic/rifle/lethal
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal

///////////////////////
// BOLT ACTION RIFLE //
///////////////////////

//Template for bolt-action rifles. Avoid changing this unless needed as it can cause issues with the other bolt action rifles.
/obj/item/gun/ballistic/rifle/boltaction
	name = "bolt action template"
	desc = "If you see this - cry to a coder. Something's wrong."
	icon_state = "moistnugget"
	item_state = "moistnugget"
	slot_flags = 0 //no ITEM_SLOT_BACK sprite, alas
	inaccuracy_modifier = 0.5
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction
	var/bolt_open = FALSE
	can_bayonet = TRUE
	knife_x_offset = 27
	knife_y_offset = 13

/obj/item/gun/ballistic/rifle/boltaction/pump(mob/M)
	playsound(M, 'sound/weapons/shotgunpump.ogg', 60, 1)
	pump_unload(M)
	pump_reload(M)
	update_icon()	//I.E. fix the desc
	return 1

/obj/item/gun/ballistic/rifle/boltaction/attackby(obj/item/A, mob/user, params)
	if(!bolt_open)
		to_chat(user, "<span class='notice'>The bolt is closed!</span>")
		return
	. = ..()

/obj/item/gun/ballistic/rifle/boltaction/examine(mob/user)
	. = ..()
	. += "The bolt is [bolt_open ? "open" : "closed"]."

//Lee-Enfield Mk III			Keywords: .308, Low-tier loot. 			Note: Canon? No. But it's purpose is for the Commando Carbine. Fills a needed niche of low-tier but still hard-ish hitting rifle. Plus makes more sense than a KAR or Mosin; may swap to a Springfield.
/obj/item/gun/ballistic/rifle/enfield
	name = "Lee-Enfield Mk III"
	desc = "An ancient rifle from the olden days of trench warfare and world wars. This rifle fell out of service centuries ago but became a sought after gun for hunters and renactors alike."
	icon_state = "moistnugget"
	item_state = "moistnugget"
	slot_flags = 0 //no ITEM_SLOT_BACK sprite, alas
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction
	can_scope = TRUE
	scope_state = "mosin_scope"
	scope_x_offset = 3
	scope_y_offset = 13
	can_bayonet = TRUE
	bayonet_state = "lasmusket"
	knife_x_offset = 22
	knife_y_offset = 21
	extra_damage = 4
	fire_delay = 3.5
	pump_sound = 'sound/weapons/boltpump.ogg'
	fire_sound = 'sound/f13weapons/boltfire.ogg'
	can_suppress = FALSE

//Hunting Rifle					Keywords: .308, High damage, Slow firing.
/obj/item/gun/ballistic/rifle/remington
	name = "Hunting rifle"
	desc = "A sturdy hunting rifle, chambered in .308. and in use before the war."
	icon_state = "308"
	item_state = "308"
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/remington
	sawn_desc = "A hunting rifle, crudely shortened with a saw. It's far from accurate, but the short barrel makes it quite portable."
	fire_sound = 'sound/f13weapons/hunting_rifle.ogg'
	extra_damage = 8
	fire_delay = 4
	extra_penetration = 0.1
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	can_scope = TRUE
	scope_state = "rifle_scope"
	scope_x_offset = 4
	scope_y_offset = 12
	pump_sound = 'sound/weapons/boltpump.ogg'
	untinkerable = FALSE

/obj/item/gun/ballistic/rifle/remington/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/circular_saw) || istype(A, /obj/item/gun/energy/plasmacutter))
		sawoff(user)
	if(istype(A, /obj/item/melee/transforming/energy))
		var/obj/item/melee/transforming/energy/W = A
		if(W.active)
			sawoff(user)

//"Paciencia"					Kewords: UNIQUE, .308, Huge damage boost.
/obj/item/gun/ballistic/rifle/remington/paciencia
	name = "Paciencia"
	desc = "A modified .308 hunting rifle with a reduced magazine but an augmented receiver. A Mexican flag is wrapped around the stock. You only have three shots- make them count."
	icon_state = "paciencia"
	item_state = "paciencia"
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/remington/paciencia
	fire_delay = 5
	extra_damage = 20 //60 damage- hits as hard as an AMR!
	extra_penetration = 0.2
	untinkerable = TRUE

/obj/item/gun/ballistic/rifle/remington/paciencia/attackby(obj/item/A, mob/user, params) //no sawing off this one
	if(istype(A, /obj/item/circular_saw) || istype(A, /obj/item/gun/energy/plasmacutter))
		return
	else if(istype(A, /obj/item/melee/transforming/energy))
		var/obj/item/melee/transforming/energy/W = A
		if(W.active)
			return
	else
		..()

/obj/item/gun/ballistic/rifle/automatic/shoot_live_shot(mob/living/user, pointblank = FALSE, mob/pbtarget, message = 1, stam_cost = 0)
	..()
	src.pump(user)


//Cowboy Repeater				Keywords: .357 Magnum, Repeater rifle, auto-cycles
/obj/item/gun/ballistic/rifle/automatic/hunting/cowboy
	name = "Cowboy repeater"
	desc = "A lever action rifle chambered in .357 Magnum. Smells vaguely of whiskey and cigarettes."
	icon_state = "cowboyrepeater"
	item_state = "cowboyrepeater"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube357
	fire_sound = 'sound/f13weapons/cowboyrepeaterfire.ogg'
	pump_sound = 'sound/f13weapons/cowboyrepeaterreload.ogg'
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	untinkerable = FALSE
	fire_delay = 3
	can_scope = TRUE
	scope_state = "leveraction_scope"
	scope_x_offset = 11
	scope_y_offset = 21
	extra_damage = 5

//Trail Carbine				Keywords: .44 Magnum, Repeater rifle, auto-cycles
/obj/item/gun/ballistic/rifle/automatic/hunting/trail
	name = "Trail carbine"
	desc = "A lever action rifle chambered in .44 Magnum."
	icon_state = "trailcarbine"
	item_state = "trailcarbine"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube44
	fire_sound = 'sound/f13weapons/44mag.ogg'
	pump_sound = 'sound/f13weapons/cowboyrepeaterreload.ogg'
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	untinkerable = FALSE
	fire_delay = 3
	can_scope = TRUE
	scope_state = "leveraction_scope"
	scope_x_offset = 11
	scope_y_offset = 21

//Brush Gun				Keywords: .45-70, Repeater rifle, auto-cycles
/obj/item/gun/ballistic/rifle/automatic/hunting/brush
	name = "Brush gun"
	desc = "A short lever action rifle chambered in the heavy 45-70 round. Issued to NCR Veteran Rangers in the absence of heavier weaponry."
	icon_state = "brushgun"
	item_state = "brushgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube4570
	fire_sound = 'sound/f13weapons/brushgunfire.ogg'
	pump_sound = 'sound/f13weapons/cowboyrepeaterreload.ogg'
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	untinkerable = FALSE
	fire_delay = 3
	can_scope = TRUE
	scope_state = "leveraction_scope"
	scope_x_offset = 11
	scope_y_offset = 21

//////////////////////////////
// LASER AND PLASMA MUSKETS //
//////////////////////////////

//These are commented out as they have the following issues: 1. Balance wise, they don't work well. 2. They fill no niche nor are worth the cost of the ammo used in them. 3. Players get upset when they get one of these instead of a bolt action due to ammo costs.
//Maybe these can be overhauled at some point to not be as bad; but for now they're disabled. Keeping the code though since it has potential.

/*
/obj/item/gun/ballistic/rifle/lasmusket
	name = "Laser musket"
	desc = "In the wasteland, one must make do. And making do is what the creator of this weapon does. Made from metal scraps, electronic parts. an old rifle stock and a Nuka Cola bottle full of dreams, the Laser Musket is sure to stop anything in their tracks and make those raiders think twice."
	icon = 'icons/fallout/objects/guns/energy.dmi'
	icon_state = "lasmusket"
	item_state = "lasmusket"
	lefthand_file = 'icons/fallout/onmob/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/guns_righthand.dmi'
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lasmusket
	//nocase = TRUE
	var/bolt_open = FALSE
	can_bayonet = TRUE
	fire_delay = 15
	knife_x_offset = 23
	knife_y_offset = 21
	bayonet_state = "lasmusket"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	isenergy = TRUE
	can_scope = TRUE
	scope_state = "lasmusket_scope"
	scope_x_offset = 9
	scope_y_offset = 20
	fire_sound = 'sound/f13weapons/lasmusket_fire.ogg'
	pump_sound = 'sound/f13weapons/lasmusket_crank.ogg'
	equipsound = 'sound/f13weapons/equipsounds/aep7equip.ogg'
	untinkerable = FALSE

/obj/item/gun/ballistic/rifle/plasmacaster
	name = "Plasma musket"
	desc = "For those who like using scavenged high tech components duct-taped to old gun parts, complete with a recharge handle stolen from a coffee grinder."
	icon = 'icons/fallout/objects/guns/energy.dmi'
	icon_state = "plasmamusket"
	item_state = "plasmamusket"
	lefthand_file = 'icons/fallout/onmob/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/guns_righthand.dmi'
	mag_type = /obj/item/ammo_box/magazine/internal/plasmacaster
	var/bolt_open = FALSE
	can_bayonet = TRUE
	fire_delay = 20
	bayonet_state = "lasmusket"
	knife_x_offset = 23
	knife_y_offset = 21
	can_scope = TRUE
	scope_state = "lasmusket_scope"
	scope_x_offset = 9
	scope_y_offset = 20
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	isenergy = TRUE
	fire_sound = 'sound/f13weapons/lasmusket_fire.ogg'
	pump_sound = 'sound/f13weapons/lasmusket_crank.ogg'
	equipsound = 'sound/f13weapons/equipsounds/aep7equip.ogg'
	untinkerable = FALSE
*/

/////////////////////////////////////
// MAGAZINE FED BOLT-ACTION RIFLES //
/////////////////////////////////////

//Template for magazine-fed bolt actions as opposed to internal magazine ones.
/obj/item/gun/ballistic/rifle/mag
	name = "magazine fed bolt-action rifle template"
	desc = "should not exist."
	extra_speed = 800

/obj/item/gun/ballistic/rifle/mag/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to remove the magazine.</span>"

/obj/item/gun/ballistic/rifle/mag/AltClick(mob/living/user)
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(magazine)
		magazine.forceMove(drop_location())
		user.put_in_hands(magazine)
		magazine.update_icon()
		if(magazine.ammo_count())
			playsound(src, 'sound/weapons/gun_magazine_remove_full.ogg', 70, 1)
		else
			playsound(src, "gun_remove_empty_magazine", 70, 1)
		magazine = null
		to_chat(user, "<span class='notice'>You pull the magazine out of \the [src].</span>")
	else if(chambered)
		AC.forceMove(drop_location())
		AC.bounce_away()
		chambered = null
		to_chat(user, "<span class='notice'>You unload the round from \the [src]'s chamber.</span>")
		playsound(src, "gun_slide_lock", 70, 1)
	else
		to_chat(user, "<span class='notice'>There's no magazine in \the [src].</span>")
	update_icon()
	return

/obj/item/gun/ballistic/rifle/mag/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"]"

//Varmint Rifle					Keywords: 5.56, Low-tier loot, Med-damage, Decent fire rate
/obj/item/gun/ballistic/rifle/mag/varmint
	name = "varmint rifle"
	desc = "A simple bolt action rifle in 5.56mm calibre. Easy to use and maintain."
	icon_state = "varmint_rifle"
	item_state = "varmintrifle"
	force = 18
	mag_type = /obj/item/ammo_box/magazine/m556/rifle
	init_mag_type = /obj/item/ammo_box/magazine/m556/rifle/small
	fire_delay = 3
	spread = 0
	extra_damage = 8
	extra_penetration = 0.1
	can_bayonet = FALSE
	can_scope = TRUE
	scope_state = "scope_short"
	scope_x_offset = 4
	scope_y_offset = 12
	can_suppress = TRUE
	suppressor_state = "rifle_suppressor"
	suppressor_x_offset = 27
	suppressor_y_offset = 31
	fire_sound = 'sound/f13weapons/varmint_rifle.ogg'

//"Ratslayer"					Keywords: UNIQUE, 5.56, High pen
/obj/item/gun/ballistic/rifle/mag/varmint/ratslayer
	name = "Ratslayer"
	desc = "A modified varmint rifle with better stopping power, a scope, and suppressor. Oh, don't forget the sick paint job."
	icon_state = "rat_slayer"
	item_state = "ratslayer"
	extra_damage = 7
	extra_penetration = 0.2
	suppressed = 1
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	can_scope = FALSE
	fire_sound = 'sound/weapons/Gunshot_large_silenced.ogg'

//Commando Carbine				Keywords: .45 ACP, Mid-tier loot, High damage			Note: Canon? No. But fills a balance niche and has an interesting sprite. Basically a modified Lee-Enflield Mk III.
/obj/item/gun/ballistic/rifle/mag/commando
	name = "commando carbine"
	desc = "A integrally suppressed bolt action carbine, it appears to use some ancinet bolt-action rifle design but modified to take a lower-caliber round. Uses .45 socom magazines."
	icon_state = "commando"
	item_state = "varmintrifle"
	mag_type = /obj/item/ammo_box/magazine/m45
	extra_damage = 6
	extra_penetration = 0.1
	fire_delay = 5
	spread = 1
	can_unsuppress = FALSE
	can_scope = TRUE
	suppressed = 1
	can_scope = TRUE
	scope_state = "scope_medium"
	scope_x_offset = 6
	scope_y_offset = 14
	fire_sound = 'sound/weapons/Gunshot_large_silenced.ogg'

//Commando DMR				Keywords: LEGION, .45 ACP, Very high damage				Note: Canon? No. But fills a balance niche and has an interesting sprite. Basically a modified Lee-Enflield Mk III but now on steroids.
/obj/item/gun/ballistic/rifle/mag/commando/dmr
	name = "destroyer carbine"
	desc = "A integrally suppressed bolt action carbine, it appears to use some ancinet bolt-action rifle design but modified to take a lower-caliber round. Someone took a perfectly good rifle and mangled it into this amazing nightmare with a longer barrel for precision accuracy. Uses .45 socom magazines."
	icon_state = "destroyer"
	item_state = "varmintrifle"
	mag_type = /obj/item/ammo_box/magazine/m45
	extra_damage = 10
	extra_penetration = 0.15
	fire_delay = 6
	spread = 0
	can_unsuppress = FALSE
	suppressed = 1
	can_scope = TRUE
	scope_state = "scope_medium"
	scope_x_offset = 6
	scope_y_offset = 14
	fire_sound = 'sound/weapons/Gunshot_large_silenced.ogg'

//.50 BMG AMR					Keywords: .50, Very high damage, Very high AP, Big-Fuckin'-Gun
/obj/item/gun/ballistic/rifle/mag/antimateriel
	name = "anti-materiel rifle"
	desc = "A heavy, high-powered sniper rifle chambered in .50 caliber ammunition. Although relatively austere, you're still pretty sure it could take the head off a deathclaw."
	icon_state = "amr"
	item_state = "sniper"
	mag_type = /obj/item/ammo_box/magazine/amr
	untinkerable = TRUE
	extra_damage = 10
	fire_delay = 10
	recoil = 1
	spread = 0
	force = 10 //Big clumsy and sensitive scope, makes for a poor club
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13
	fire_sound = 'sound/f13weapons/antimaterielfire.ogg'
	pump_sound = 'sound/f13weapons/antimaterielreload.ogg'
