indexing
	description: "Reads BLAST score matrix files from an input stream."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	BLAST_SCORE_MATRIX_READER

create
	make

feature {NONE} -- Initialization

	make is
			-- Create reader.
		do
		end

feature -- Access

	line_number: INTEGER
			-- Current line number.

	line: STRING
			-- Current line.

	row: INTEGER
			-- Current row index.

	column: INTEGER
			-- Current column index.

	item: ARRAY2 [DOUBLE]
			-- Resulting matrix.

	source_alphabet: ARRAYED_LIST [CHARACTER]
			-- Alphabet of source sequences.

	target_alphabet: ARRAYED_LIST [CHARACTER]
			-- Alphabet of target sequences.

feature -- Basic operations

	read_from_stream (s: KI_TEXT_INPUT_STREAM) is
			-- Read score matrix from input stream `s'.
		require
			not_void: s /= Void
			is_open: s.is_open_read
		do
			input_stream := s

			create item.make ({CHARACTER}.max_value, {CHARACTER}.max_value)

			if not input_stream.end_of_input then
				input_start
				row := 0
				column := 0
				read_header
				read_rows
			else
				raise ("Empty input", False, False)
			end
		end

feature {NONE} -- Implementation

	input_stream: KI_TEXT_INPUT_STREAM
			-- Input stream.

	input_off: BOOLEAN is
			-- Is input stream off?
		do
			Result := input_stream.end_of_input
		end

	input_start is
			-- Reset reader.
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

	read_header is
			-- Read header line.
		local
			done: BOOLEAN
		do
			from
			until
				done or input_off
			loop
				-- Skip empty lines and comments.
				if not line.is_empty then
					if line @ 1 /= '#' then
						parse_header
						row := row + 1
						done := True
					end
				end

				input_forth
			end

			if not done then
				raise ("Header expected", True, False)
			end
		end

	parse_header is
			-- Parse header line and create target alphabet.
		local
			l: LIST [STRING]
			c: CHARACTER
		do
			create target_alphabet.make (4)

			l := line.split (' ')
			from
				column := 1
				l.start
			until
				l.off
			loop
				if not l.item.is_empty then
					if l.item.count = 1 then
						c := (l.item @ 1).as_upper
						if not target_alphabet.has (c) then
							target_alphabet.extend (c)
							column := column + 1
						else
							raise ("Duplicate element", True, True)
						end
					else
						raise ("Multi-character element", True, True)
					end
				end

				l.forth
			end
		end

	read_rows is
			-- Read all lines following header line.
		local
		do
			create source_alphabet.make (4)

			from
			until
				input_off
			loop
				-- Skip empty lines and comments.
				if not line.is_empty then
					if line @ 1 /= '#' then
						parse_row
						row := row + 1
					end
				end

				input_forth
			end

			if source_alphabet.count = 0 then
				raise ("Rows expected", True, False)
			end
		end

	parse_row is
			-- Parse a row line.
		local
			l: LIST [STRING]
			c, d: CHARACTER
		do
			l := line.split (' ')

			if l.count >= 2 then
				column := 0
				l.start

				if l.item.count = 1 then
					c := (l.item @ 1).as_upper
					if not source_alphabet.has (c) then
						source_alphabet.extend (c)
						column := column + 1

						from
							l.forth
						until
							l.off or (column > target_alphabet.count)
						loop
							if not l.item.is_empty then
								if l.item.is_double then
									d := target_alphabet [column]
									item [c.code, d.code] := l.item.to_double
									column := column + 1
								else
									raise ("Cannot parse score", True, True)
								end
							end

							l.forth
						end

						if not l.off or (column <= target_alphabet.count) then
							raise ("Invalid number of columns", True, False)
						end
					else
						raise ("Duplicate element", True, True)
					end
				else
					raise ("Multi-character element", True, True)
				end
			end
		end

	raise (m: STRING; include_line, include_cell: BOOLEAN) is
			-- Raise an exception with message `m'.
		local
			s: STRING
			ex: DEVELOPER_EXCEPTION
		do
			s := m
			if include_line then
				s := s + " at line " + line_number.out
			end
			if include_cell then
				s := s + " in cell [" + row.out + ", " + column.out + "]"
			end

			create ex
			ex.set_message (s)
			ex.raise
		end

end
