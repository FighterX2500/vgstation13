var/global/narsie_behaviour = "CultStation13"

/obj/machinery/singularity/narsie //Moving narsie to its own file for the sake of being clearer
	name = "Nar-Sie"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
	icon = 'icons/obj/narsie.dmi'
	icon_state = "narsie"
	pixel_x = -89
	pixel_y = -85

	current_size = 9 //It moves/eats like a max-size singulo, aside from range. --NEO.
	contained = 0 // Are we going to move around?
	dissipate = 0 // Do we lose energy over time?
	grav_pull = 10 //How many tiles out do we pull?
	consume_range = 3 //How many tiles out do we eat

	//all the snowflakes that nar-sie won't touch
	var/list/uneatable_narsie = list(
		/obj/effect/overlay,
		/mob/dead,
		/mob/camera,
		/mob/new_player,
		/obj/effect/rune,
		/obj/effect/decal/cleanable/blood,
		/obj/effect/decal/remains,
		/obj/effect/forcefield/cult,
		/mob/living/simple_animal/construct,
		/mob/living/simple_animal/hostile/scarybat/cult,
		/mob/living/simple_animal/hostile/creature/cult,
		/mob/living/simple_animal/hostile/faithless/cult,
		/obj/item/weapon/tome,
		/obj/item/weapon/melee/cultblade,
		/obj/item/weapon/table_parts/wood,
		/obj/item/device/soulstone,
		/obj/structure/constructshell,
		/obj/structure/cult,
		/obj/structure/bookcase,
		/obj/structure/stool/bed/chair/wood/wings,
		/obj/structure/mineral_door/wood,
		/obj/structure/table/woodentable,
		/obj/structure/bookcase,
		/turf/simulated/floor/carpet,
		/turf/simulated/floor/engine/cult,
		/turf/simulated/wall/cult
		)

	//our space stations are different
	var/list/random_structure = list(
		/obj/structure/cult/talisman,
		/obj/structure/cult/forge,
		/obj/structure/cult/tome
		//obj/structure/cult/pylon	Not included on purpose. These are what lights are replaced by.
		)

	//Machinery that gets deleted and isn't replaced with cult structures
	var/list/trash_machinery = list(
		/obj/machinery/camera,
		/obj/machinery/power,
		/obj/machinery/light_switch,
		/obj/machinery/firealarm,
		/obj/machinery/alarm,
		/obj/machinery/atm,
		/obj/machinery/hologram,
		/obj/machinery/atmospherics,
		/obj/machinery/status_display,
		/obj/machinery/newscaster,
		/obj/machinery/media,
		/obj/machinery/door_control,
		/obj/machinery/access_button,
		/obj/machinery/embedded_controller,
		/obj/machinery/navbeacon,
		/obj/machinery/gateway,
		/obj/machinery/space_heater,
		/obj/machinery/crema_switch,
		/obj/machinery/portable_atmospherics,
		/obj/machinery/pos,
		/obj/machinery/requests_console,
		/obj/machinery/computer/security/telescreen,
		/obj/machinery/conveyor_switch,
		/obj/machinery/conveyor,
		/obj/machinery/vending/wallmed1,
		/obj/machinery/flasher,
		/obj/machinery/flasher_button,
		/obj/machinery/cell_charger,
		/obj/machinery/meter,
		/obj/machinery/keycard_auth,
		/obj/machinery/airlock_sensor,
		/obj/machinery/turretid,
		/obj/machinery/bot
		)//I know just how snowflake heavy those lists are, but the result is worth it.

/obj/machinery/singularity/narsie/large
	name = "Nar-Sie"
	icon = 'icons/obj/narsie.dmi'
	icon_state = "narsie"//mobs perceive the geometer of blood through their see_narsie proc

	// Pixel stuff centers Narsie.
	pixel_x = -236
	pixel_y = -256
	luminosity = 1
	l_color = "#3e0000"


	current_size = 12
	consume_range = 12 // How many tiles out do we eat.
	var/announce=1

/obj/machinery/singularity/narsie/large/New(var/cultspawn=0)
	..()
	if(announce)
		world << "<font size='15' color='red'><b>[uppertext(name)] HAS RISEN</b></font>"

	if (emergency_shuttle)
		emergency_shuttle.incall(0.3) // Cannot recall.

	if(cultspawn)
		SetUniversalState(/datum/universal_state/hell)
/*
	updateicon()
*/

/obj/machinery/singularity/narsie/process()
	eat()

	if (!target || prob(5))
		pickcultist()

	move()

	if (prob(25))
		mezzer()

/obj/machinery/singularity/narsie/large/eat()
	set background = BACKGROUND_ENABLED
	for (var/atom/A in orange(consume_range, src))
		consume(A)

/obj/machinery/singularity/narsie/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(M.stat == CONSCIOUS)
			if(!iscultist(M))
				M << "\red You feel your sanity crumble away in an instant as you gaze upon [src.name]..."
				M.apply_effect(3, STUN)


/obj/machinery/singularity/narsie/Bump(atom/A)
	if(isturf(A))
		narsiewall(A)
	else if(istype(A, /obj/structure/cult))
		del(A)
	else
		consume(A)

/obj/machinery/singularity/narsie/Bumped(atom/A)
	if(isturf(A))
		narsiewall(A)
	else if(istype(A, /obj/structure/cult))
		del(A)
	else
		consume(A)

/obj/machinery/singularity/narsie/move(var/force_move = 0)
	if(!move_self)
		return 0

	var/movement_dir = pick(alldirs - last_failed_movement)

	if(force_move)
		movement_dir = force_move

	if(target && prob(60))
		movement_dir = get_dir(src,target)

	spawn(0)
		step(src, movement_dir)
		narsiefloor(get_turf(loc))
		for (var/mob/M in orange(consume_range+10, src))
			M.see_narsie(src)
	spawn(1)
		step(src, movement_dir)
		narsiefloor(get_turf(loc))
		for (var/mob/M in orange(consume_range+10, src))
			M.see_narsie(src)
	return 1

/obj/machinery/singularity/narsie/proc/narsiefloor(var/turf/T)//leaving "footprints"
	if(!(istype(T, /turf/simulated/floor/engine/cult/narsie)||istype(T, /turf/simulated/wall/cult)||istype(T, /turf/space)))
		T.ChangeTurf(/turf/simulated/floor/engine/cult/narsie)

/obj/machinery/singularity/narsie/proc/narsiewall(var/turf/T)
	T.desc = "An opening has been made on that wall, but who can say if what you seek truly lies on the other side?"
	T.icon = 'icons/turf/walls.dmi'
	T.icon_state = "cult-narsie"
	T.opacity = 0
	T.density = 0
	luminosity = 1
	l_color = "#3e0000"

/obj/machinery/singularity/narsie/consume(const/atom/A) //Has its own consume proc because it doesn't need energy and I don't want BoHs to explode it. --NEO
//NEW BEHAVIOUR
	if(narsie_behaviour == "CultStation13")
		if (is_type_in_list(A, uneatable_narsie))
			return 0
	//MOB PROCESSING
		if (istype(A, /mob/living/) && (get_dist(A, src) <= 7))//approximatively matches the size of its sprite, so you won't get gobbled up before you can even see it. hopefully.
			var/mob/living/M = A
			if(iscultist(M) && M.client)
				var/mob/living/simple_animal/construct/harvester/C = new /mob/living/simple_animal/construct/harvester(get_turf(M))
				M.mind.transfer_to(C)
				C << "<span class='sinister'>The Geometer of Blood is overjoyed to be reunited with its followers, and accepts your body in sacrifice. As reward, you have been gifted with the shell of an Harvester.<br>Your tendrils can use and draw runes without need for a tome, your eyes can see beings through walls, and your mind can open any door. Use these assets to serve Nar-Sie and bring him any remaining living human in the world.<br>You can teleport yourself back to Nar-Sie along with any being under yourself at any time using your \"Harvest\" spell.</span>"
			M.dust()
	//ITEM PROCESSING
		else if (istype(A, /obj/))
			if(istype(A, /obj/item/))
				if(istype(A, /obj/item/weapon/table_parts))
					new /obj/item/weapon/table_parts/wood(A.loc)
				else if(istype(A, /obj/item/device/flashlight/lamp))
					new /obj/structure/cult/pylon(A.loc)
			else if(istype(A, /obj/machinery/) && !is_type_in_list(A, trash_machinery))
				if(istype(A, /obj/machinery/light))
					new /obj/structure/cult/pylon(A.loc)
				else if((istype(A, /obj/machinery/computer)) || (istype(A, /obj/machinery/librarycomp)))
					new /obj/structure/cult/tome(A.loc)
				else if(istype(A, /obj/machinery/cooking))
					new /obj/structure/cult/talisman(A.loc)
				else if(istype(A, /obj/machinery/vending))
					new /obj/structure/cult/forge(A.loc)
				else if(istype(A, /obj/machinery/door/unpowered/shuttle))
					new /obj/structure/mineral_door/wood(A.loc)
				else if(!istype(A, /obj/machinery/door))
					var/I = pick(random_structure)
					new I(A.loc)
				if (A && !istype(A, /obj/structure/reagent_dispensers/fueltank))
					A.ex_act(1)
			else if(istype(A, /obj/structure/))
				if(istype(A, /obj/structure/grille))
					var/turf/F0 = get_turf(A)
					F0.ChangeTurf(/turf/simulated/wall/cult)
					var/turf/simulated/wall/cult/F1 = F0
					F1.del_suppress_resmoothing=1 // Reduce lag from wallsmoothing.
				else if(istype(A, /obj/structure/table))
					new /obj/structure/table/woodentable(A.loc)
				else if(istype(A, /obj/structure/shuttle/engine/propulsion))
					var/turf/F20 = get_turf(A)
					F20.ChangeTurf(/turf/simulated/wall/cult)
					var/turf/simulated/wall/cult/F21 = F20
					F21.del_suppress_resmoothing=1
				else if(istype(A, /obj/structure/shuttle/engine/heater))
					new /obj/structure/cult/pylon(A.loc)
				else if(istype(A, /obj/structure/stool))
					var/obj/structure/stool/bed/chair/wood/wings/I2 = new /obj/structure/stool/bed/chair/wood/wings(A.loc)
					I2.dir = A.dir
				if (A && !istype(A, /obj/structure/reagent_dispensers/fueltank))
					A.ex_act(1)
			if (A)
				qdel(A)

	//TURF PROCESSING
		else if (isturf(A))
			var/dist = get_dist(A, src)

			for (var/atom/movable/AM in A.contents)
				if (AM == src) // This is the snowflake.
					continue

				if (dist <= consume_range)
					consume(AM)
					continue

				if (dist > consume_range && canPull(AM))
					if (is_type_in_list(AM, uneatable_narsie))
						continue

					if (101 == AM.invisibility)
						continue

					spawn (0)
						step_towards(AM, src)

			if (dist <= consume_range && !istype(A, /turf/space))
				var/turf/T = A
				if (istype(T,/turf/simulated/shuttle/wall))
					T.icon = 'icons/turf/walls.dmi'
					T.icon_state = "cult"
				else if(istype(T,/turf/simulated/wall)|| istype(T,/turf/unsimulated/wall))
					var/turf/simulated/wall/W = T
					if(!istype(T,/turf/unsimulated/wall))
						W.del_suppress_resmoothing=1 // Reduce lag from wallsmoothing.
					W.ChangeTurf(/turf/simulated/wall/cult)
				else if(istype(T,/turf/simulated/floor) || istype(T,/turf/simulated/shuttle/floor) || istype(T,/turf/simulated/shuttle/floor4) || istype(T,/turf/unsimulated/floor))
					var/turf/simulated/floor/F = T
					F.ChangeTurf(/turf/simulated/floor/engine/cult)
				else if(!istype(T,/turf/unsimulated/beach))
					T.ChangeTurf(/turf/space)
//OLD BEHAVIOUR
	else if(narsie_behaviour == "Nar-Singulo")
		if (is_type_in_list(A, uneatable))
			return 0

		if (istype(A, /mob/living/))
			var/mob/living/C2 = A
			C2.dust() // Changed from gib(), just for less lag.

		else if (istype(A, /obj/))
			A.ex_act(1)

			if (A)
				qdel(A)
		else if (isturf(A))
			var/dist = get_dist(A, src)

			for (var/atom/movable/AM2 in A.contents)
				if (AM2 == src) // This is the snowflake.
					continue

				if (dist <= consume_range)
					consume(AM2)
					continue

				if (dist > consume_range && canPull(AM2))
					if (is_type_in_list(AM2, uneatable))
						continue

					if (101 == AM2.invisibility)
						continue

					spawn (0)
						step_towards(AM2, src)

			if (dist <= consume_range && !istype(A, /turf/space))
				var/turf/T2 = A
				T2.ChangeTurf(/turf/space)

/obj/machinery/singularity/narsie/ex_act(severity) //No throwing bombs at it either. --NEO
	return

/obj/machinery/singularity/narsie/proc/pickcultist() //Narsie rewards his cultists with being devoured first, then picks a ghost to follow. --NEO
	var/list/cultists = list()
	for(var/datum/mind/cult_nh_mind in ticker.mode.cult)
		if(!cult_nh_mind.current)
			continue
		if(cult_nh_mind.current.stat)
			continue
		var/turf/pos = get_turf(cult_nh_mind.current)
		if(pos.z != src.z)
			continue
		cultists += cult_nh_mind.current
	if(cultists.len)
		acquire(pick(cultists))
		return
		//If there was living cultists, it picks one to follow.
	for(var/mob/living/carbon/human/food in living_mob_list)
		if(food.stat)
			continue
		var/turf/pos = get_turf(food)
		if(pos.z != src.z)
			continue
		cultists += food
	if(cultists.len)
		acquire(pick(cultists))
		return
		//no living cultists, pick a living human instead.
	for(var/mob/dead/observer/ghost in player_list)
		if(!ghost.client)
			continue
		var/turf/pos = get_turf(ghost)
		if(pos.z != src.z)
			continue
		cultists += ghost
	if(cultists.len)
		acquire(pick(cultists))
		return
		//no living humans, follow a ghost instead.

/obj/machinery/singularity/narsie/proc/acquire(const/mob/food)
	var/capname = uppertext(name)

	target << "\blue <b>[capname] HAS LOST INTEREST IN YOU.</b>"
	target = food

	if (ishuman(target))
		target << "\red <b>[capname] HUNGERS FOR YOUR SOUL.</b>"
	else
		target << "\red <b>[capname] HAS CHOSEN YOU TO LEAD HIM TO HIS NEXT MEAL.</b>"

/*
////////////////Glow//////////////////
/obj/machinery/singularity/narsie/proc/updateicon()
	overlays = 0
	var/overlay_layer = LIGHTING_LAYER+1
	overlays += image(icon,"glow-[icon_state]",overlay_layer)
*/


/**
 * Wizard narsie.
 */
/obj/machinery/singularity/narsie/wizard
	grav_pull = 0

/obj/machinery/singularity/narsie/wizard/eat()
	set background = BACKGROUND_ENABLED

	if (defer_powernet_rebuild != 2)
		defer_powernet_rebuild = 1

	for (var/turf/T in trange(consume_range, src))
		consume(T)

	if (defer_powernet_rebuild != 2)
		defer_powernet_rebuild = 0

/**
 * MR. CLEAN
 */
var/global/mr_clean_targets = list(
	/obj/effect/decal/cleanable,
	/obj/effect/decal/mecha_wreckage,
	/obj/effect/decal/remains,
	/obj/effect/spacevine,
	/obj/effect/spacevine_controller,
	/obj/effect/biomass,
	/obj/effect/biomass_controller,
	/obj/effect/rune,
	/obj/effect/blob,
	/obj/effect/spider
)

/obj/machinery/singularity/narsie/large/clean // Mr. Clean.
	name = "Mr. Clean"
	desc = "This universe is dirty. Time to change that."
	icon = 'icons/obj/mrclean.dmi'
	icon_state = ""

/obj/machinery/singularity/narsie/large/clean/process()
	eat()

	if (!target || prob(5))
		pickuptrash()

	move()

	if (prob(25))
		mezzer()

/obj/machinery/singularity/narsie/large/clean/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(M.stat == CONSCIOUS)
			M << "<span class='warning'> You take a moment to admire [src.name] hard at work...</span>"
			M.apply_effect(3, STUN)

/obj/machinery/singularity/narsie/large/clean/update_icon()
	overlays = 0

	if (target && !isturf(target))
		overlays += "eyes"

/obj/machinery/singularity/narsie/large/clean/acquire(var/mob/food)
	..()
	update_icon()

/obj/machinery/singularity/narsie/large/clean/consume(const/atom/A)
	if (is_type_in_list(A, uneatable))
		return 0

	if (istype(A, /mob/living/))
		if (isrobot(A))
			var/mob/living/silicon/robot/R = A

			if (R.mmi)
				del(R.mmi) // Nuke MMI.
		qdel(A) // Just delete it.
	else if (is_type_in_list(A, mr_clean_targets))
		qdel(A)
	else if (isturf(A))
		var/turf/T = A
		T.clean_blood()
		var/dist = get_dist(T, src)

		for (var/atom/movable/AM in T.contents)
			if (AM == src) // This is the snowflake.
				continue

			if (dist <= consume_range)
				consume(AM)
				continue

			if (dist > consume_range && canPull(AM))
				if (is_type_in_list(AM, uneatable))
					continue

				if (101 == AM.invisibility)
					continue

				spawn (0)
					step_towards(AM, src)

/*
 * Mr. Clean just follows the dirt and grime.
 */
/obj/machinery/singularity/narsie/large/clean/proc/pickuptrash()
	var/list/targets = list()
	for(var/obj/effect/E in world)
		if(is_type_in_list(E, mr_clean_targets) && E.z == src.z)
			targets += E
	if(targets.len)
		acquire(pick(targets))
		return