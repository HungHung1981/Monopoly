(** [render state] returns a text-art board showing spaces, players, property
    owners, and development levels in board order. *)
val render : State.state -> string list
