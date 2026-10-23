////////////
///CONDOM///
////////////

//Packaged condom

/obj/item/condom_pack
	name = "condom pack"
	desc = "Don't worry, I have protection."
	icon_state = "condom_pack_pink"
	base_icon_state = "condom_pack"
	icon = 'modular_skyrat/modules/modular_items/lewd_items/icons/obj/lewd_items/lewd_items.dmi'
	w_class = WEIGHT_CLASS_TINY
	/// The current color of the condom, can be changed and affects sprite
	var/current_color = "pink"

/obj/item/condom_pack/Initialize(mapload)
	. = ..()
	//color chosen randomly when item spawned
	current_color = pick("pink", "teal", "blue") // SPLURT EDIT - Include classic blue condom color
	update_appearance()

/obj/item/condom_pack/update_icon_state()
	. = ..()
	// SPLURT EDIT START - Support classic blue condom sprite
	if(current_color == "blue")
		icon = 'modular_zzplurt/icons/obj/lewd/condom.dmi'
		icon_state = "b_condom_wrapped"
		return
	icon = 'modular_skyrat/modules/modular_items/lewd_items/icons/obj/lewd_items/lewd_items.dmi'
	// SPLURT EDIT END
	icon_state = "[base_icon_state]_[current_color]"

/obj/item/condom_pack/attack_self(mob/user)
	to_chat(user, span_notice("You start to open the condom pack..."))
	if(!do_after(user, 1.5 SECONDS, target = user))
		return
	conditional_pref_sound(src.loc, 'sound/items/poster/poster_ripped.ogg', 50, TRUE)
	var/obj/item/clothing/sextoy/condom/removed_condom = new /obj/item/clothing/sextoy/condom

	user.put_in_hands(removed_condom)
	removed_condom.current_color = current_color // SPLURT EDIT - Preserve all condom colors
	removed_condom.update_appearance()
	qdel(src)

//Opened condom

/obj/item/clothing/sextoy/condom
	name = "condom"
	desc = "I wonder if I can put this over my head..."
	icon_state = "condom_pink_unused"
	base_icon_state = "condom"
	icon = 'modular_skyrat/modules/modular_items/lewd_items/icons/obj/lewd_items/lewd_items.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/current_color = "pink"
	var/condom_state = "unused"
	lewd_slot_flags = LEWD_SLOT_PENIS
	// SPLURT EDIT START - Multi-load reagent container, growth stages, and head-wearable sprite
	slot_flags = ITEM_SLOT_HEAD
	worn_icon = 'modular_zzplurt/icons/obj/lewd/condom.dmi'
	worn_icon_state = "condomhat"
	/// Maximum reagent volume the condom can hold across multiple loads
	var/volume = 300
	/// Minimum fluid volume added per climax when worn
	var/min_load_volume = 50
	// SPLURT EDIT END

/obj/item/clothing/sextoy/condom/Initialize(mapload)
	. = ..()
	// SPLURT EDIT START - Initialize 300u reagent container and listen for reagent updates
	create_reagents(volume, INJECTABLE | DRAWABLE | DRAINABLE | REFILLABLE | TRANSPARENT | NO_REACT)
	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(on_reagent_change))
	update_appearance()
	// SPLURT EDIT END

// SPLURT EDIT START - Multi-load growth, worn sprite appearance, and throw-splat mechanics
/// Returns the visual inflation stage (0 to 4) based on the total reagent volume inside the condom
/obj/item/clothing/sextoy/condom/proc/get_condom_fill_stage()
	if(!reagents || reagents.total_volume <= 0 || condom_state == TRAIT_CONDOM_BROKEN)
		return 0
	switch(reagents.total_volume)
		if(0.01 to 49)
			return 1
		if(50 to 100)
			return 2
		if(101 to 249)
			return 3
		if(250 to INFINITY)
			return 4
	return 0

/// Handles reagent volume changes to update the condom's size state, name, and worn overlay
/obj/item/clothing/sextoy/condom/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	if(reagents?.total_volume > 0 && condom_state == "unused")
		condom_state = "dirty"
	update_appearance()
	if(ishuman(loc))
		var/mob/living/carbon/human/holder_human = loc
		if(holder_human.penis == src)
			holder_human.update_inv_penis()

/obj/item/clothing/sextoy/condom/update_name(updates = ALL)
	. = ..()
	if(condom_state == TRAIT_CONDOM_BROKEN)
		name = "broken condom"
		return
	switch(get_condom_fill_stage())
		if(0)
			name = (condom_state == "unused") ? "condom" : "used condom"
		if(1)
			name = "filled condom"
		if(2)
			name = "medium filled condom"
		if(3)
			name = "large filled condom"
		if(4)
			name = "huge filled condom"
// SPLURT EDIT END

/obj/item/clothing/sextoy/condom/update_icon_state()
	. = ..()
	// SPLURT EDIT START - Update icon and icon_state for inflation stages and blue condoms
	var/fill_stage = get_condom_fill_stage()
	if(fill_stage > 0)
		icon = 'modular_zzplurt/icons/obj/lewd/condom.dmi'
		switch(fill_stage)
			if(1)
				icon_state = "b_condom_inflated"
			if(2)
				icon_state = "b_condom_inflated_med"
			if(3)
				icon_state = "b_condom_inflated_large"
			if(4)
				icon_state = "b_condom_inflated_huge"
		return
	if(current_color == "blue")
		icon = 'modular_zzplurt/icons/obj/lewd/condom.dmi'
		switch(condom_state)
			if("unused")
				icon_state = "b_condom"
			if("used")
				icon_state = "b_condom_out"
			if("dirty")
				icon_state = "b_condom_cum"
			if(TRAIT_CONDOM_BROKEN)
				icon_state = "b_condom_broken"
			else
				icon_state = "b_condom"
		return
	icon = 'modular_skyrat/modules/modular_items/lewd_items/icons/obj/lewd_items/lewd_items.dmi'
	// SPLURT EDIT END
	icon_state = "[base_icon_state]_[current_color]_[condom_state]"

// SPLURT EDIT START - Worn sprite helpers, multi-load filling, and throw-splat
/obj/item/clothing/sextoy/condom/build_worn_icon(
	default_layer = 0,
	default_icon_file = null,
	isinhands = FALSE,
	female_uniform = NO_FEMALE_UNIFORM,
	override_state = null,
	override_file = null,
	bodyshape = NONE,
	mutant_styles = NONE,
)
	if(!isinhands && default_layer == PENIS_LAYER)
		return mutable_appearance()
	return ..()

/// Returns the base latex hex color for the worn penis overlay
/obj/item/clothing/sextoy/condom/proc/get_base_latex_color()
	switch(current_color)
		if("pink")
			return "#FF88CC"
		if("teal")
			return "#55E0D0"
		if("blue")
			return "#77CCFF"
	return "#FFFFFF"

/// Returns the blended color for the worn penis overlay, shifting toward the contained fluid color as it fills
/obj/item/clothing/sextoy/condom/proc/get_worn_condom_color()
	var/fill_stage = get_condom_fill_stage()
	if(fill_stage > 0 && length(reagents?.reagent_list))
		var/reagent_color = mix_color_from_reagents(reagents.reagent_list)
		if(reagent_color)
			return BlendRGB(get_base_latex_color(), reagent_color, min(0.85, 0.35 + (fill_stage * 0.12)))
	return get_base_latex_color()

/// Returns the alpha transparency for the worn penis overlay based on fill stage
/obj/item/clothing/sextoy/condom/proc/get_worn_condom_alpha()
	switch(get_condom_fill_stage())
		if(0)
			return 150
		if(1)
			return 175
		if(2)
			return 195
		if(3)
			return 215
		if(4)
			return 235
	return 150

/// Updates the condom's reagents and sprite when climaxed into
/obj/item/clothing/sextoy/condom/proc/condom_use(mob/living/user, obj/item/organ/genital/testicles/testicles)
	if(condom_state == TRAIT_CONDOM_BROKEN)
		return FALSE
	condom_state = "dirty"
	if(reagents)
		var/datum/reagent/fluid_type = testicles?.internal_fluid_datum || /datum/reagent/consumable/cum
		var/load_amount = max(testicles ? testicles.cumshot_size : min_load_volume, min_load_volume)
		var/available_space = max(0, reagents.maximum_volume - reagents.total_volume)
		var/target_add = min(load_amount, available_space)
		var/transferred = 0
		if(testicles?.reagents?.total_volume && target_add > 0)
			transferred = testicles.reagents.trans_to(src, min(testicles.cumshot_size, target_add), transferred_by = user)
		testicles?.reagents?.remove_all(testicles.cumshot_size)
		if(transferred < target_add)
			reagents.add_reagent(fluid_type, target_add - transferred)
		if(load_amount > available_space && user)
			user.add_cum_splatter_floor(get_turf(user), cum_reagent = fluid_type)
	update_appearance()
	if(ishuman(loc))
		var/mob/living/carbon/human/holder_human = loc
		if(holder_human.penis == src)
			holder_human.update_inv_penis()
	return TRUE

/obj/item/clothing/sextoy/condom/examine(mob/user)
	. = ..()
	switch(get_condom_fill_stage())
		if(1)
			. += span_notice("It has been filled with a load and stretches slightly.")
		if(2)
			. += span_notice("It is swollen with multiple loads.")
		if(3)
			. += span_notice("It is stretched large and heavy with multiple loads!")
		if(4)
			. += span_notice("It is stretched to a massive size, completely packed full of loads!")

/obj/item/clothing/sextoy/condom/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!.)
		splat(hit_atom)

/// Bursts a filled condom when thrown at a target, splashing its contents onto the turf
/obj/item/clothing/sextoy/condom/proc/splat(atom/hit_atom)
	if(isliving(loc) || !reagents?.total_volume)
		return
	var/turf/target_turf = get_turf(hit_atom)
	reagents.expose(hit_atom, TOUCH)
	if(target_turf)
		new /obj/effect/decal/cleanable/cum(target_turf)
		playsound(target_turf, 'sound/misc/splort.ogg', 50, TRUE)
	qdel(src)
// SPLURT EDIT END

//When condom equipped we doing stuff
/obj/item/clothing/sextoy/condom/lewd_equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ORGAN_SLOT_PENIS)
		if(condom_state == "unused")
			condom_state = "used"
			update_appearance()
		// SPLURT EDIT START - Play latex sound and feedback message from old SPLURT code
		conditional_pref_sound(user, 'modular_skyrat/modules/modular_items/lewd_items/sounds/latex.ogg', 50, TRUE)
		to_chat(user, span_userlove("Your penis feels more safe!"))
		// SPLURT EDIT END

// SPLURT EDIT START - Render worn condom overlay on the penis sprite and show in organ description
/obj/item/organ/genital/penis/get_description_string(datum/sprite_accessory/genital/gas)
	. = ..()
	if(owner?.is_wearing_condom() && !(sheath != SHEATH_NONE && aroused == AROUSAL_NONE))
		var/mob/living/carbon/human/human_owner = owner
		if(istype(human_owner) && human_owner.penis)
			. += " It is wrapped in \a [human_owner.penis]."

/datum/bodypart_overlay/mutant/genital/penis/get_overlay(obj/item/bodypart/limb, layer_index, layer_real)
	. = ..()
	if(!islist(.) || !length(.))
		return .
	var/mob/living/carbon/human/wearer = limb?.owner
	if(!istype(wearer) || !wearer.is_wearing_condom())
		return .
	var/obj/item/organ/genital/penis/penis_organ = wearer.get_organ_slot(ORGAN_SLOT_PENIS)
	if(penis_organ && penis_organ.sheath != SHEATH_NONE && penis_organ.aroused == AROUSAL_NONE)
		return .
	var/obj/item/clothing/sextoy/condom/worn_condom = wearer.penis
	if(!istype(worn_condom))
		return .
	var/mutable_appearance/base_shaft = .[1]
	if(!istype(base_shaft))
		return .
	var/mutable_appearance/condom_overlay = new(base_shaft)
	condom_overlay.color = worn_condom.get_worn_condom_color()
	condom_overlay.alpha = worn_condom.get_worn_condom_alpha()
	. += condom_overlay

/datum/bodypart_overlay/mutant/genital/penis/icon_render_key(obj/item/bodypart/limb)
	. = ..()
	var/mob/living/carbon/human/wearer = limb?.owner
	if(istype(wearer) && wearer.is_wearing_condom())
		var/obj/item/clothing/sextoy/condom/worn_condom = wearer.penis
		if(istype(worn_condom))
			. += "condom_[worn_condom.current_color]_[worn_condom.get_condom_fill_stage()]"
// SPLURT EDIT END
