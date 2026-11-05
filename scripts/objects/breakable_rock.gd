extends StaticBody2D
## Roccia crepata: si rompe solo con una chela che ha "breaks_rock" (Martello).


func take_hit(_damage: int, _from: Vector2, claw: StringName) -> void:
	if GameState.CLAWS.get(claw, {}).get("breaks_rock", false):
		$CollisionShape2D.set_deferred(&"disabled", true)
		var tw := create_tween()
		tw.tween_property(self, "scale", Vector2(1.3, 1.3), 0.08)
		tw.tween_property(self, "modulate:a", 0.0, 0.12)
		tw.tween_callback(queue_free)
	else:
		GameState.say("La roccia è crepata... serve una chela più robusta.")
