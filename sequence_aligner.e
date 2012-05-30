indexing
	description: "Abstract aligner class."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SEQUENCE_ALIGNER [G, H]

inherit
	SEQUENCE_COMPARER [G, H]
		rename
			output as best_score
		end

feature -- Access

	best_alignments: LINKED_LIST [ALIGNMENT [G, H]]
			-- Best alignments. All have same score: `best_score'.
			-- Meaningful only after `find_best_alignments' call.

feature -- Basic operations

	find_best_alignments is
			-- Find the best alignments and update `best_alignments'.
		deferred
		end

--	max (a, b: DOUBLE): DOUBLE is
--			-- max {a, b}
--		do
--			if a >= b then
--				Result := a
--			else
--				Result := b
--			end
--		end

--	triple_max (a, b, c: DOUBLE): DOUBLE is
--			-- max {a, b, c}
--		do
--			if a >= b then
--				Result := a.max (c)
--			else
--				Result := b.max (c)
--			end
--		end

--	quadruple_max (a, b, c, d: DOUBLE): DOUBLE is
--			-- max {a, b, c, d}
--		do
--			if a >= b then
--				Result := triple_max (a, c, d)
--			else
--				Result := triple_max (b, c, d)
--			end
--		end

end
