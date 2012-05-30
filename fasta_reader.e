indexing
	description: "Reads FASTA formatted files sequentially."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	FASTA_READER

create
	make

feature {NONE} -- Initialization

	make (s: KI_TEXT_INPUT_STREAM) is
			-- Create reader for stream `s'.
		local
			i: INTEGER
		do
			input_stream := s

			create {CHARACTER_8_SET}allowed_elements.make
			from
				i := {CHARACTER}.min_value
			until
				i > {CHARACTER}.max_value
			loop
				allowed_elements.put (i.to_character_8)
				i := i + 1
			end
		end

feature -- Access

	line_number: INTEGER
			-- Current line number.

	line: STRING
			-- Current line.

	index: INTEGER
			-- Index of current item.

	identifier: STRING
			-- Identifier of current item.

	item: ADVANCED_STRING
			-- Sequence of current item.

	allowed_elements: SET [CHARACTER]
			-- Set of allowed elements.

feature -- Status report

	off: BOOLEAN
			-- Is there no current item?

feature -- Cursor movement

	start is
			-- Move to first position if any.
		do
			index := 0
			identifier := Void
			item := Void

			if not input_stream.end_of_input then
				off := False
				input_start
				forth
			else
				off := True
			end
		ensure
			first_item: not off implies (index = 1)
		end

	forth is
			-- Move to next position; if no next position,
			-- ensure that `off' will be true.
		require
			not_off: not off
		do
			index := index + 1
			identifier := Void
			item := Void

			read_identifier
			if identifier /= Void then
				read_sequence
			else
				off := True
			end
		ensure
			next_item: index = old index + 1
		end

feature -- Element change

	set_allowed_elements (v: like allowed_elements) is
			-- Let `allowed_elements' be `v'.
		require
			not_void: v /= Void
		do
			allowed_elements := v
		end

feature {NONE} -- Implementation

	input_stream: KI_TEXT_INPUT_STREAM
			-- Input stream.

	input_off: BOOLEAN is
			-- Is input off?
		do
			Result := input_stream.end_of_input
		end

	input_start is
			-- Go to first position.
		do
			line_number := 0
			-- input_stream.rewind
			input_forth
		ensure
			first_line: not input_off implies (line_number = 1)
		end

	input_forth is
			-- Read a string until new line or end of input.
			-- Make result available in `line'.
		do
			line_number := line_number + 1
			line := Void

			input_stream.read_line
			line := input_stream.last_string
			line.left_adjust
			line.right_adjust
		ensure
			next_line: line_number = old line_number + 1
		end

	read_identifier is
			-- Read identifier line.
		require
			not_off: not off
		local
			id: STRING
		do
			from
				id := Void
			until
				(id /= Void) or input_off
			loop
				-- Skip empty lines and expect a '>' for identifier.
				if not line.is_empty then
					inspect line @ 1
					when '>' then			-- Identifier line: set identifier.
						id := line.substring (2, line.count)
						id.left_adjust
					when ';' then			-- Comment line: skip.
						-- do nothing
					else					-- Unexpected content.
						raise ("Identifier line expected", True, False)
					end
				end

				input_forth
			end

			if id /= Void then
				identifier := id
			end
		ensure
			not_void_or_input_off: (identifier /= Void) or input_off
		end

	read_sequence is
			-- Read item lines.
		local
			seq: ADVANCED_STRING
			done: BOOLEAN
		do
			from
				create seq.make_from_string ("")
			until
				done or input_off
			loop
				-- Skip empty lines and read until an identifier line.
				if not line.is_empty then
					inspect line @ 1
					when '>' then			-- Identifier line: stop reading.
						done := True
					when ';' then			-- Comment line: skip.
						-- do nothing
					else					-- Sequence line: extend item.
						seq.append (line.as_upper)
					end
				end

				if not done then
					input_forth
				end
			end

			seq.prune_whitespaces

			if seq.is_empty then
				raise ("Empty item", True, False)
			end

			if not seq.all_in (allowed_elements) then
				raise ("Invalid element '" + seq.failed_character.out + "'", False, True)
			end

			item := seq
		ensure
			not_void: item /= Void
		end

	raise (m: STRING; include_line: BOOLEAN; include_identifier: BOOLEAN) is
			-- Raise an exception with message `m'.
		local
			s: STRING
			ex: DEVELOPER_EXCEPTION
		do
			s := m
			if include_line then
				s := s + " at line " + line_number.out
			end
			if include_identifier then
				s := s + " in '" + identifier + "'"
			end

			create ex
			ex.set_message (s)
			ex.raise
		end

end
