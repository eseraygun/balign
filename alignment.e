indexing
	description: "Stores all information about an alignment."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	ALIGNMENT [G, H]

create
	make

feature {NONE} -- Initialization

	make (n, se, te: INTEGER) is
			-- Initialize alignment with `source_end'=`se' and `target_end'=`te'.
		do
			create aligned_source.make (n)
			create aligned_target.make (n)
			source_end := se
			target_end := te
		end

feature -- Access

	aligned_source: FIXED_LIST [G]
			-- Aligned subsequence of `source'.

	aligned_target: FIXED_LIST [H]
			-- Aligned subsequence of `target'.

	source_start: INTEGER
			-- Start point of source subsequence.

	source_end: INTEGER
			-- End point of source subsequence.

	target_start: INTEGER
			-- Start point of target subsequence.

	target_end: INTEGER
			-- End point of target subsequence.

	count: INTEGER is
			-- Length of alignment.
		do
			Result := aligned_source.count
		ensure
			definition_1: Result = aligned_source.count
			definition_2: Result = aligned_target.count
		end

	score: DOUBLE
			-- Raw alignment score.

	identity: INTEGER
			-- Number of identical elements.

	similarity: INTEGER
			-- Number of similar elements.

	gaps: INTEGER
			-- Number of gaps.

feature -- Element change

	set_source_start (v: like source_start) is
			-- Let `source_start' be `v'.
		require
			positive: v > 0
		do
			source_start := v
		end

	set_target_start (v: like target_start) is
			-- Let `target_start' be `v'.
		require
			positive: v > 0
		do
			target_start := v
		end

	append_match (s: G; t: H; identical: BOOLEAN; match_score: DOUBLE) is
			-- Prepend a matching to alignment.
		do
			aligned_source.extend (s)
			aligned_target.extend (t)
			score := score + match_score
			if identical then
				identity := identity + 1
			end
			if match_score > 0.0 then
				similarity := similarity + 1
			end
		end

	unappend_match (identical: BOOLEAN; match_score: DOUBLE) is
			-- Unprepend last matching from alignment.
		do
			aligned_source.finish
			aligned_source.remove
			aligned_target.finish
			aligned_target.remove
			score := score - match_score
			if identical then
				identity := identity - 1
			end
			if match_score > 0.0 then
				similarity := similarity - 1
			end
		end

	append_gap (s: G; t: H; gap_penalty: DOUBLE) is
			-- Prepend an insertion (or gap) to alignment.
		do
			aligned_source.extend (s)
			aligned_target.extend (t)
			score := score - gap_penalty
			gaps := gaps + 1
		end

	unappend_gap (gap_penalty: DOUBLE) is
			-- Unprepend last insertion (or gap) from alignment.
		do
			aligned_source.finish
			aligned_source.remove
			aligned_target.finish
			aligned_target.remove
			score := score + gap_penalty
			gaps := gaps - 1
		end

feature -- Conversion

	reversed: ALIGNMENT [G, H] is
			-- Reversed version of current alignment.
		do
			Result := deep_twin
			Result.reverse
		end

feature -- Basic operations

	reverse is
			-- Reverse aligned sequences.
		local
			i, n, half_n: INTEGER
			ts: G
			tt: H
		do
			n := count
			half_n := n // 2
			from i := 1 until i > half_n loop
				ts := aligned_source [i]
				aligned_source [i] := aligned_source [n - i + 1]
				aligned_source [n - i + 1] := ts

				tt := aligned_target [i]
				aligned_target [i] := aligned_target [n - i + 1]
				aligned_target [n - i + 1] := tt

				i := i + 1
			end
		end

end
