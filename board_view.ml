let printable text =
  String.map (fun character ->
    let code = Char.code character in
    if code < 32 || code = 127 then ' ' else character) text

let fit width text =
  let text = printable text in
  let text =
    if String.length text > width then String.sub text 0 width else text in
  text ^ String.make (width - String.length text) ' '

let board_positions width height =
  let bottom =
    List.init width (fun i -> (height - 1, width - 1 - i)) in
  let left =
    List.init (height - 1) (fun i -> (height - 2 - i, 0)) in
  let top =
    List.init (width - 1) (fun i -> (0, i + 1)) in
  let right =
    List.init (height - 2) (fun i -> (i + 1, width - 1)) in
  bottom @ left @ top @ right

let render state =
  let spaces = State.get_all_board_spaces state in
  let players = State.get_all_players state in
  let player_codes =
    List.mapi (fun index (id, _) -> (id, Char.chr (Char.code 'A' + index)))
      players in
  let player_locations =
    List.map (fun (id, _) ->
      (id, State.get_player_location_index id state))
      players in
  let properties = State.get_all_properties state in
  let tiles =
    List.mapi (fun index space ->
      let occupants =
        List.fold_right (fun (id, location_index) markers ->
          if location_index = index then
            String.make 1 (List.assoc id player_codes) :: markers
          else markers)
          player_locations []
        |> String.concat "" in
      let property_details =
        if List.mem space properties then begin
          let owner_detail =
            match State.get_property_owner space state with
            | State.Bank -> []
            | State.Player id ->
                (match List.assoc_opt id player_codes with
                | Some code -> ["O:" ^ String.make 1 code]
                | None -> ["O:?"]) in
          let development = State.get_property_dev_stage space state in
          owner_detail @
          (if development > 0 then ["D:" ^ string_of_int development] else [])
        end else [] in
      let status =
        (if occupants = "" then [] else ["P:" ^ occupants]) @ property_details
        |> String.concat " " in
      (index, space, status))
      spaces in
  match tiles with
  | [] -> ["MONOPOLY BOARD"; ""; "The selected board has no spaces."]
  | _ ->
      let largest_index = List.length tiles - 1 |> string_of_int in
      let index_width = max 2 (String.length largest_index) in
      let cell_width =
        List.fold_left (fun width (_, _, status) ->
          max width (String.length status))
          (max 8 index_width)
          tiles in
      let count = List.length tiles in
      let dimension_sum = (count + 5) / 2 in
      let width = max 2 ((dimension_sum + 1) / 2) in
      let height = max 2 (dimension_sum - width) in
      let perimeter = board_positions width height in
      let grid = Array.make_matrix height width None in
      let rec assign_tiles positions tiles =
        match positions, tiles with
        | (row, col) :: remaining_positions, tile :: remaining_tiles ->
            grid.(row).(col) <- Some tile;
            assign_tiles remaining_positions remaining_tiles
        | _ -> () in
      assign_tiles perimeter tiles;
      let render_line line_index row =
        let rec render_cells = function
          | [] -> ""
          | None :: remaining ->
              let rec count_empty count = function
                | None :: rest -> count_empty (count + 1) rest
                | rest -> (count, rest) in
              let count, rest = count_empty 1 remaining in
              String.make (count * (cell_width + 1)) ' ' ^
              render_cells rest
          | Some (index, space, status) :: remaining ->
              let text =
                match line_index with
                | 0 -> Printf.sprintf "%0*d" index_width index
                | 1 -> space
                | _ -> status in
              "|" ^ fit cell_width text ^ render_cells remaining in
        render_cells (Array.to_list grid.(row)) ^ "|" in
      let board_rows =
        List.init height (fun row ->
          [render_line 0 row; render_line 1 row; render_line 2 row])
        |> List.concat in
      let player_legend =
        List.mapi (fun index (id, _) ->
          let location =
            List.assoc id player_locations in
          Printf.sprintf "%c: %s ($%d, space %0*d)"
            (Char.chr (Char.code 'A' + index)) (printable id)
            (State.get_player_money id state) index_width location)
          players in
      ["MONOPOLY BOARD (clockwise from space 00)"] @ board_rows @
      [""; "Space 00 is at the bottom right; spaces proceed clockwise.";
       "P: marks occupants; O:A identifies an owner; D:n is development."]
      @ player_legend
