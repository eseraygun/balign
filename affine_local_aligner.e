indexing
	description: "Aligner class for affine Smith-Waterman algorithm."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	AFFINE_LOCAL_ALIGNER [G, H]

inherit
	AFFINE_ALIGNER [G, H]

create
	make

feature {NONE} -- Initialization

	make is
			-- Initialize aligner.
		do
			score_matrix := agent identity_score_matrix_function
			gap_open_penalty := 1.0
			gap_extension_penalty := 1.0
		end

feature -- Basic operations

	find_best_alignments is
			-- Find the best alignments and update `best_alignments'.
		local
			i, j: INTEGER
			a: ALIGNMENT [G, H]
		do
			create best_alignments.make
			from i := 2 until i > f.height loop
				from j := 2 until j > f.width loop
					if f [i, j].m = best_score then
						create a.make (source.count.max (target.count), i - 1, j - 1)
						traceback_m (a, i, j)
					end
					j := j + 1
				end
				i := i + 1
			end
		end

feature {NONE} -- Implementation: Matrix computation

	initialize_f is
			-- Reset alignment matrix `f'.
		local
			i, j: INTEGER
			cell: AFFINE_ALIGNMENT_MATRIX_CELL
		do
			create f.make (source.count + 1, target.count + 1)

			-- Set first cell.
			create cell.make (0.0, {INTEGER}.min_value, {INTEGER}.min_value)
			f [1, 1] := cell

			-- Set first column.
			from i := 2 until i > f.height loop
				create cell.make (0.0, {INTEGER}.min_value, {INTEGER}.min_value)
				f [i, 1] := cell
				i := i + 1
			end

			-- Set first row.
			from j := 2 until j > f.width loop
				create cell.make (0.0, {INTEGER}.min_value, {INTEGER}.min_value)
				f [1, j] := cell
				j := j + 1
			end

			-- Set remaining cells
			from i := 2 until i > f.height loop
				from j := 2 until j > f.width loop
					create cell.make_zero
					f [i, j] := cell
					j := j + 1
				end
				i := i + 1
			end
		end

	compute_m (i, j: INTEGER; match_score: DOUBLE) is
			-- Compute M [i, j]: result of matching operation.
		do
			current_cell.set_m ((0.0).max (f [i - 1, j - 1].max + match_score))
		end

	compute_ix (i, j: INTEGER) is
			-- Compute Ix [i, j]: result of insertion on source sequence.
		local
			up: AFFINE_ALIGNMENT_MATRIX_CELL
		do
			up := f [i - 1, j]
			current_cell.set_ix (
				(up.m - gap_open_penalty).max (up.ix - gap_extension_penalty))
		end

	compute_iy (i, j: INTEGER) is
			-- Compute Iy [i, j]: result of insertion on target sequence.
		local
			left: AFFINE_ALIGNMENT_MATRIX_CELL
		do
			left := f [i, j - 1]
			current_cell.set_iy (
				(left.m - gap_open_penalty).max (left.iy - gap_extension_penalty))
		end

feature {NONE} -- Implementation: Traceback

	find_best_score is
			-- Find best score and update `best_score'.
		local
			i, j: INTEGER
		do
			best_score := 0.0
			from i := 1 until i > f.height loop
				from j := 1 until j > f.width loop
					if f [i, j].m > best_score then
						best_score := f [i, j].m
					end
					j := j + 1
				end
				i := i + 1
			end
		end

	traceback_m (a: ALIGNMENT [G, H]; start_i, start_j: INTEGER) is
			-- Start from cell [i, j].m and list all best alignments.
			-- Recursive!
		require
			not_first_row_or_first_column: (start_i > 1) and (start_j > 1)
		local
			i, j: INTEGER
			done: BOOLEAN
			s: G
			t: H
			diagonal: AFFINE_ALIGNMENT_MATRIX_CELL
			max_score: DOUBLE
		do
			from
				i := start_i
				j := start_j
			invariant
				(i > 0) and (j > 0)
			until
				done
			loop
				i := i - 1
				j := j - 1

				s := source [i]
				t := target [j]
				a.append_match (s, t, identical (s, t), score_matrix.item ([s, t]))

				diagonal := f [i, j]
				max_score := diagonal.max

				if diagonal.m = max_score then
					if diagonal.m = 0.0 then
						finish_traceback (a.deep_twin, i, j)
						done := True
					end
				else
					done := True
				end
				if diagonal.ix = max_score then
					traceback_ix (a.deep_twin, i, j)
				end
				if diagonal.iy = max_score then
					traceback_iy (a.deep_twin, i, j)
				end
			end
		end

	traceback_ix (a: ALIGNMENT [G, H]; start_i, j: INTEGER) is
			-- Start from cell [i, j].ix and list all best alignments.
			-- Recursive!
		require
			not_first_row: start_i > 1
		local
			i: INTEGER
			done: BOOLEAN
			up: AFFINE_ALIGNMENT_MATRIX_CELL
			sm, si: DOUBLE
			b: ALIGNMENT [G, H]
		do
			from
				i := start_i
			invariant
				i > 0
			until
				done
			loop
				i := i - 1

				up := f [i, j]
				sm := up.m - gap_open_penalty
				si := up.ix - gap_extension_penalty

				if sm >= si then
					b := a.deep_twin
					b.append_gap (source [i], target_gap, gap_open_penalty)
					traceback_m (b, i, j)
				end
				if si >= sm then
					a.append_gap (source [i], target_gap, gap_extension_penalty)
				else
					done := True
				end
			end
		end

	traceback_iy (a: ALIGNMENT [G, H]; i, start_j: INTEGER) is
			-- Start from cell [i, j].iy and list all best alignments.
			-- Recursive!
		require
			not_first_column: start_j > 1
		local
			j: INTEGER
			done: BOOLEAN
			left: AFFINE_ALIGNMENT_MATRIX_CELL
			sm, si: DOUBLE
			b: ALIGNMENT [G, H]
		do
			from
				j := start_j
			invariant
				j > 0
			until
				done
			loop
				j := j - 1

				left := f [i, j]
				sm := left.m - gap_open_penalty
				si := left.iy - gap_extension_penalty

				if sm >= si then
					b := a.deep_twin
					b.append_gap (source_gap, target [j], gap_open_penalty)
					traceback_m (b, i, j)
				end
				if si >= sm then
					a.append_gap (source_gap, target [j], gap_extension_penalty)
				else
					done := True
				end
			end
		end

end
