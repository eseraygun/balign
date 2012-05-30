note
	description: "Compound sequence version of BALIGN_CONFIG."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	BALIGN_COMPOUND_CONFIG

inherit
	BALIGN_CONFIG [CHARACTER_PAIR]

feature -- Access

	secondary_source_alphabet: ARRAYED_LIST [CHARACTER]
			-- Alphabet of secondary source sequences.

	secondary_target_alphabet: ARRAYED_LIST [CHARACTER]
			-- Alphabet of secondary target sequences.

	secondary_score_matrix: ARRAY2 [like output]
			-- Secondary score matrix.

	balance: DOUBLE
			-- Interpolation parameter for primary and secondary structures.
			-- 0: Consider only primary sequences.
			-- 1: Consider only secondary sequences.

feature -- Measurement

feature -- Status report

feature -- Status setting

feature -- Cursor movement

feature -- Element change

	set_secondary_score_matrix (v: STRING) is
			-- Create secondary score matrix corresponding to string `v'.
		require
			not_void: v /= Void
		local
			f: KL_TEXT_INPUT_FILE
			s: KL_STRING_INPUT_STREAM
			reader: BLAST_SCORE_MATRIX_READER
			ex: DEVELOPER_EXCEPTION
		do
			secondary_score_matrix := Void

			create f.make (v)
			if f.exists then
				f.open_read
				create reader.make
				reader.read_from_stream (f)
				f.close
			elseif stored_score_matrices.has (v.as_lower) then
				create s.make (stored_score_matrices [v.as_lower])
				create reader.make
				reader.read_from_stream (s)
			else
				create {FILE_NOT_FOUND}ex
				ex.set_message (v)
				ex.raise
			end

			secondary_score_matrix := reader.item
			secondary_source_alphabet := reader.source_alphabet
			secondary_target_alphabet := reader.target_alphabet
		ensure
			secondary_score_matrix_created: secondary_score_matrix /= Void
		end

	set_balance (v: DOUBLE) is
			-- Let `balance' be `v'.
		do
			balance := v
		end

feature -- Removal

feature -- Resizing

feature -- Transformation

feature -- Conversion

feature -- Duplication

feature -- Miscellaneous

feature -- Basic operations

feature -- Obsolete

feature -- Inapplicable

feature {NONE} -- Implementation

	set_gaps is
			-- Set comparer gaps.
		local
			gap: CHARACTER_PAIR
		do
			create gap.make ('-', '-')
			comparer.set_source_gap (gap)
			comparer.set_target_gap (gap)
		end

	score_matrix_function (s, t: CHARACTER_PAIR): DOUBLE is
			-- Return score matrix entry for elements `s' and `t'.
		do
			Result := score_matrix [s.first.code, t.first.code] * (1.0 - balance) +
				secondary_score_matrix [s.second.code, t.second.code] * balance
		end

	chain_to_string (c: CHAIN [CHARACTER_PAIR]): STRING is
			-- Convert element chain `c' to a string.
		local
			p, s: ADVANCED_STRING
		do
			create p.make_from_primary_chain (c)
			create s.make_from_secondary_chain (c)
			Result := p + "%N" + s
		end

end
