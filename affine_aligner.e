indexing
	description: "Abstract aligner class for affine gap penalties."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	AFFINE_ALIGNER [G, H]

inherit
	SEQUENCE_ALIGNER [G, H]

feature -- Access

	gap_open_penalty: DOUBLE
			-- Gap open penalty.

	gap_extension_penalty: DOUBLE
			-- Gap extension penalty.

feature -- Element change

	set_gap_open_penalty (v: like gap_open_penalty) is
			-- Let `gap_open_penalty' be `v'.
		require
			non_negative_gap_open_penalty: v >= 0.0
		do
			gap_open_penalty := v
		end

	set_gap_extension_penalty (v: like gap_extension_penalty) is
			-- Let `gap_extension_penalty' be `v'.
		require
			positive_gap_extension_penalty: v > 0.0
		do
			gap_extension_penalty := v
		end

feature -- Basic operation


	run is
			-- Compute alignment matrix for `source' and `target'.
			-- Update `best_score'.
		local
			i, j: INTEGER
		do
			initialize_f

			from i := 2 until i > f.height loop
				from j := 2 until j > f.width loop
					current_cell := f [i, j]
					compute_m (i, j, score_matrix.item ([source [i - 1], target [j - 1]]))
					compute_ix (i, j)
					compute_iy (i, j)
					j := j + 1
				end
				i := i + 1
			end

			find_best_score
		end

feature {AFFINE_ALIGNER} -- Implementation: Matrix computation

	f: ARRAY2 [AFFINE_ALIGNMENT_MATRIX_CELL]
			-- Alignment matrix (F).

	current_cell: AFFINE_ALIGNMENT_MATRIX_CELL

	initialize_f is
			-- Reset alignment matrix `f'.
		deferred
		end

	compute_m (i, j: INTEGER; match_score: DOUBLE) is
			-- Compute M [i, j]: result of matching operation.
		deferred
		end

	compute_ix (i, j: INTEGER) is
			-- Compute Ix [i, j]: result of insertion on source sequence.
		deferred
		end

	compute_iy (i, j: INTEGER) is
			-- Compute Iy [i, j]: result of insertion on target sequence.
		deferred
		end

feature {AFFINE_ALIGNER} -- Implementation: Traceback

	find_best_score is
			-- Find best score and update `best_score'.
		deferred
		end

	finish_traceback (a: ALIGNMENT [G, H]; i, j: INTEGER) is
			-- Reverse generated alignment and add it into best alignments.
		require
			consistent_scores: a.score = best_score
		do
			a.set_source_start (i)
			a.set_target_start (j)
			a.reverse
			best_alignments.force (a)
		end

end
