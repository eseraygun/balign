indexing
	description: "Aligner class for affine Needleman-Wunsch algorithm."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	AFFINE_GLOBAL_ALIGNER [G, H]

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
			a: ALIGNMENT [G, H]
			cell: AFFINE_ALIGNMENT_MATRIX_CELL
		do
			create best_alignments.make
			cell := f [f.height, f.width]
			if cell.m = best_score then
				create a.make (source.count + target.count, f.height - 1, f.width - 1)
				traceback_m (a, f.height, f.width)
			end
			if cell.ix = best_score then
				create a.make (source.count + target.count, f.height - 1, f.width - 1)
				traceback_ix (a, f.height, f.width)
			end
			if cell.iy = best_score then
				create a.make (source.count + target.count, f.height - 1, f.width - 1)
				traceback_iy (a, f.height, f.width)
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
				create cell.make ({INTEGER}.min_value, 0.0, {INTEGER}.min_value)
				f [i, 1] := cell
				i := i + 1
			end

			-- Set first row.
			from j := 2 until j > f.width loop
				create cell.make ({INTEGER}.min_value, {INTEGER}.min_value, 0.0)
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
			current_cell.set_m (f [i - 1, j - 1].max + match_score)
		end

	compute_ix (i, j: INTEGER) is
			-- Compute Ix [i, j]: result of insertion on source sequence.
		local
			up: AFFINE_ALIGNMENT_MATRIX_CELL
		do
			up := f [i - 1, j]
			-- Do not penalize terminal gaps.
			if j < f.width then
				current_cell.set_ix (
					(up.m - gap_open_penalty).max (up.ix - gap_extension_penalty))
			else
				current_cell.set_ix (up.m.max (up.ix))
			end
		end

	compute_iy (i, j: INTEGER) is
			-- Compute Iy [i, j]: result of insertion on target sequence.
		local
			left: AFFINE_ALIGNMENT_MATRIX_CELL
		do
			left := f [i, j - 1]
			-- Do not penalize terminal gaps.
			if i < f.height then
				current_cell.set_iy (
					(left.m - gap_open_penalty).max (left.iy - gap_extension_penalty))
			else
				current_cell.set_iy (left.m.max (left.iy))
			end
		end

feature {NONE} -- Implementation: Traceback

	find_best_score is
			-- Find best score and update `best_score'.
		do
			best_score := f [f.height, f.width].max
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
			until
				done
			loop
				i := i - 1
				j := j - 1

				s := source [i]
				t := target [j]
				a.append_match (s, t, identical (s, t), score_matrix.item ([s, t]))

				if (i = 1) and (j = 1) then
					finish_traceback (a.deep_twin, i, j)
					done := True
				else
					diagonal := f [i, j]
					max_score := diagonal.max

					if diagonal.m = max_score then
						-- Do nothing.
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
			until
				done
			loop
				i := i - 1

				-- Stop on first cell.
				if (i = 1) and (j = 1) then
					a.append_gap (source [i], target_gap, 0.0)
					finish_traceback (a, i, j)
					done := True
				else
					up := f [i, j]
					-- Do not penalize terminal gaps.
					if (j > 1) and (j < f.width) then
						sm := up.m - gap_open_penalty
						si := up.ix - gap_extension_penalty
					else
						sm := up.m
						si := up.ix
					end

					if sm >= si then
						b := a.deep_twin
						b.append_gap (source [i], target_gap, up.m - sm)
						traceback_m (b, i, j)
					end
					if si >= sm then
						a.append_gap (source [i], target_gap, up.ix - si)
					else
						done := True
					end
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
			until
				done
			loop
				j := j - 1

				-- Stop on first cell.
				if (i = 1) and (j = 1) then
					a.append_gap (source_gap, target [j], 0.0)
					finish_traceback (a, i, j)
					done := True
				else
					left := f [i, j]
					-- Do not penalize terminal gaps.
					if (i > 1) and (i < f.height) then
						sm := left.m - gap_open_penalty
						si := left.iy - gap_extension_penalty
					else
						sm := left.m
						si := left.iy
					end

					if sm >= si then
						b := a.deep_twin
						b.append_gap (source_gap, target [j], left.m - sm)
						traceback_m (b, i, j)
					end
					if si >= sm then
						a.append_gap (source_gap, target [j], left.iy - si)
					else
						done := True
					end
				end
			end
		end

end
