func check_sensors():
	if hostile: 
		if $raycastpivot/RayCast.get_collider() == player:
			if self.translation.distance_to(player.translation) < view_distance:
				var a = -(self.get_transform().basis.z) # Enemy's forward vector
				var b = (player.get_translation() - self.get_translation()).normalized() # Vector from enemy to player
				if state == "sus": #if is engaged
					if acos(a.dot(b)) <= deg2rad(engaged_view_range): # If the angle is less than or equal to 60 degrees
						pass #no need to reassign
					elif state == "sus":
						state = default_behaviour #im done here
				else:              #if not yet engaged
					if acos(a.dot(b)) <= deg2rad(view_range): # If the angle is less than or equal to 60 degrees
						state = "sus" # begin sus
					elif state == "sus":
						state = default_behaviour #nevermind
			else:
				if engaged_behaviour == "inspect" && state != "inspect": #not already chasing
					move_to(nav.get_closest_point(last_known_player_location), 1, 1)
				elif state != "inspect":
					state=default_behaviour
				
				if engaged_behaviour == "chase":
					state = "chase"
		else:
			if engaged_behaviour == "inspect" && state == "sus":
				if can_act:
					move_to(last_known_player_location, 0, 1)
			elif engaged_behaviour == "chase" && state == "chase":
				if can_act:
					move_to(last_known_player_location, 0, 1)
			elif state == "sus":
				state=default_behaviour
	get_node("raycastpivot").look_at(player.translation-Vector3(0,2,0), Vector3.UP)
