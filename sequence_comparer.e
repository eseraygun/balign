indexing
	description: "Abstract sequence comparer class."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SEQUENCE_COMPARER [G, H]

feature -- Access

	source_gap: G
			-- Gap element for source sequence.

	target_gap: H
			-- Gap element for target sequence.

	score_matrix: FUNCTION [ANY, TUPLE [G, H], like output]
			-- Score matrix function agent.

	source: CHAIN [G]
			-- Source sequence.

	target: CHAIN [H]
			-- Target sequence.

	output: DOUBLE
			-- Result. Meaningful only after `run' call.

feature -- Element change

	set_source_gap (v: like source_gap) is
			-- Let `source_gap' be `v'.
		require
			v /= Void
		do
			source_gap := v
		end

	set_target_gap (v: like target_gap) is
			-- Let `target_gap' be `v'.
		require
			v /= Void
		do
			target_gap := v
		end

	set_score_matrix (v: like score_matrix) is
			-- Let `score_matrix' be `v'.
		require
			v /= Void
		do
			score_matrix := v
		end

	set_source (v: like source) is
			-- Let `source' be `v'.
		require
			v /= Void
		do
			source := v
		end

	set_target (v: like target) is
			-- Let `target' be `v'.
		require
			v /= Void
		do
			target := v
		end

feature -- Basic operations

	run is
			-- Compare `source' and `target'. Update `output'.
		deferred
		end

feature {SEQUENCE_COMPARER} -- Implementation

	identical (s: G; t: H): BOOLEAN is
			-- Is `s' equal to `t'?
			-- Needed because `is_equal' does not work for instances of possibly
			-- different classes.
		local
			s_any, t_any: ANY
		do
			s_any := s
			t_any := t
			Result := s_any.is_equal (t_any)
		end

	identity_score_matrix_function (s: G; t: H): DOUBLE is
			-- Identity score matrix. Default score matrix for new comparers.
		do
			if identical (s, t) then
				Result := 1.0
			else
				Result := 0.0
			end
		end

end
