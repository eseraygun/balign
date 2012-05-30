indexing
	description: "Reads and stores all information about a BALIGN job."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	BALIGN_SIMPLE_CONFIG

inherit
	BALIGN_CONFIG [CHARACTER]

feature {NONE} -- Initialization

feature -- Access

feature -- Element change

feature -- Basic operations

feature {NONE} -- Implementation

	set_gaps is
			-- Set comparer gaps.
		do
			comparer.set_source_gap ('-')
			comparer.set_target_gap ('-')
		end

	score_matrix_function (s, t: CHARACTER): DOUBLE is
			-- Return score matrix entry for elements `s' and `t'.
		do
			Result := score_matrix [s.code, t.code]
		end

	chain_to_string (c: CHAIN [CHARACTER]): STRING is
			-- Convert element chain `c' to a string.
		do
			create {ADVANCED_STRING}Result.make_from_chain (c)
		end

end
