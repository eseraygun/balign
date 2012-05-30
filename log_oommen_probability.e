indexing
	description: "Compares sequences using Oommen probability in log-space."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	LOG_OOMMEN_PROBABILITY [G, H]

inherit
	SEQUENCE_COMPARER [G, H]

	DOUBLE_MATH

create
	make

feature {NONE} -- Initialization

	make is
			-- Initialize `Current'.
		do
			set_insertion_distribution (agent log_of_poisson_pdf (?, 1.0))
		end

feature -- Access

	insertion_distribution: FUNCTION [ANY, TUPLE [INTEGER], like output]
			-- Logarithmic insertion probability distribution.

feature -- Element change

	set_insertion_distribution (v: like insertion_distribution) is
			-- Let `insertion_distribution' be `v'.
		require
			v /= Void
		do
			insertion_distribution := v
		end

feature -- Basic operations

	run is
			-- Compute logarithm of probability of achieving `target' given `source'.
			-- Update `output'.
			-- Original algorithm is defined in Oommen & Kashyap 1997.
			-- This is an improved and corrected version of original algorithm.
		local
			n, m: INTEGER								-- Short names for `source.count' and `target.count'.
			gg: like insertion_distribution				-- Short name for `insertion_distribution'.
			ss: like score_matrix						-- Short name for `score_matrix'.
			wes_curr, wes_prev: ARRAY2 [like output]	-- Dynamic programming matrices.
			i, e, s, lower_i, upper_s: INTEGER			-- Indices and limits.
			swap_temp: ARRAY2 [DOUBLE]					-- For matrix swap.
		do
			n := source.count
			m := target.count

			gg := insertion_distribution
			ss := score_matrix

			-- Reset output.
			output := {INTEGER}.min_value

			-- Initialize matrices.
			create wes_prev.make (n + 1, n.min (m) + 1)
			create wes_curr.make (n + 1, n.min (m) + 1)

			lower_i := (m - n).max (0)
			upper_s := m.min (n)

			-- Trace (0, E, S) plane.
			i := 0

				-- Compute (0, 0, 0) point.
				e := 0
				s := 0
				wes_curr [e + 1, s + 1] := 0.0

				-- Compute (0, E, 0) line.
				s := 0
				--from e := 1 until e > (n - m + i).max (0) loop
				from e := 1 until e > n loop
					wes_curr [e + 1, s + 1] := wes_curr [e, s + 1] + ss.item ([source [e + s], target_gap]) -- deletion
					e := e + 1
				end

				-- Compute (0, 0, S) line.
				e := 0
				from s := 1 until s > (m - i).min (upper_s) loop
					wes_curr [e + 1, s + 1] := wes_curr [e + 1, s] + ss.item ([source [e + s], target [i + s]]) -- substitution
					s := s + 1
				end

				-- Compute (0, E, S) plane.
				--from e := 1 until e > (n - m + i).max (0) loop
				from e := 1 until e > n loop
					from s := 1 until s > (m - i).min ((n - e).min (upper_s)) loop
						wes_curr [e + 1, s + 1] := log_of_sum (
							wes_curr [e,     s + 1] + ss.item ([source [e + s], target_gap]),		-- deletion
						    wes_curr [e + 1, s]     + ss.item ([source [e + s], target [i + s]]))	-- substitution
						s := s + 1
					end
					e := e + 1
				end

				-- Update output.
				if i >= lower_i then
					output := log_of_sum (
						output,
						gg.item ([i]) + log_of_combinatoric_factor (n, i) + wes_curr [n - m + i + 1, m - i + 1])
				end

				-- Move to next plane.
				swap_temp := wes_prev
				wes_prev := wes_curr
				wes_curr := swap_temp

			-- Trace (i, E, S) planes.
			from i := 1 until i > m loop
				-- Compute (i, 0, 0) point.
				e := 0
				s := 0
				wes_curr [e + 1, s + 1] := wes_prev [e + 1, s + 1] + ss.item ([source_gap, target [i + s]])

				-- Compute (i, E, 0) line.
				s := 0
				--from e := 1 until e > (n - m + i).max (0) loop
				from e := 1 until e > n loop
					wes_curr [e + 1, s + 1] := log_of_sum (
						wes_prev [e + 1, s + 1] + ss.item ([source_gap, target [i + s]]),	-- insertion
					    wes_curr [e,     s + 1] + ss.item ([source [e + s], target_gap]))	-- deletion
					e := e + 1
				end

				-- Compute (i, 0, S) line.
				e := 0
				from s := 1 until s > (m - i).min (upper_s) loop
					wes_curr [e + 1, s + 1] := log_of_sum (
						wes_prev [e + 1, s + 1] + ss.item ([source_gap,     target [i + s]]),	-- insertion
					    wes_curr [e + 1, s]     + ss.item ([source [e + s], target [i + s]]))	-- substitution
					s := s + 1
				end

				-- Compute (i, E, S) plane.
				--from e := 1 until e > (n - m + i).max (0) loop
				from e := 1 until e > n loop
					from s := 1 until s > (m - i).min ((n - e).min (upper_s)) loop
						wes_curr [e + 1, s + 1] := log_of_triple_sum (
							wes_prev [e + 1, s + 1] + ss.item ([source_gap,     target [i + s]]),	-- insertion
						    wes_curr [e,     s + 1] + ss.item ([source [e + s], target_gap]),		-- deletion
						    wes_curr [e + 1, s]     + ss.item ([source [e + s], target [i + s]]))	-- substitution
						s := s + 1
					end
					e := e + 1
				end

				-- Update output.
				if i >= lower_i then
					output := log_of_sum (
						output,
						gg.item ([i]) + log_of_combinatoric_factor (n, i) + wes_curr [n - m + i + 1, m - i + 1]) -- !
				end

				-- Move to next plane.
				swap_temp := wes_prev
				wes_prev := wes_curr
				wes_curr := swap_temp

				i := i + 1
			end
		end

feature {NONE} -- Implementation

	log_of_sum (log_x, log_y: DOUBLE): DOUBLE is
			-- Approximate logarithm of (x + y).
		require
			negative_log_x: log_x <= 0.0
			negative_log_y: log_y <= 0.0
		local
			hi, lo: DOUBLE
		do
			if log_x >= log_y then
				hi := log_x
				lo := log_y
			else
				hi := log_y
				lo := log_x
			end

			Result := hi + log (1.0 + exp (lo - hi))
		end

	log_of_triple_sum (log_x, log_y, log_z: DOUBLE): DOUBLE is
			-- Approximate logarithm of (x + y + z).
		require
			negative_log_x: log_x <= 0.0
			negative_log_y: log_y <= 0.0
			negative_log_z: log_z <= 0.0
		local
			hi, lo: DOUBLE
		do
			if (log_x >= log_y) and (log_x >= log_z) then
				hi := log_x
				lo := log_of_sum (log_y, log_z)
			elseif (log_y >= log_z) and (log_y >= log_x) then
				hi := log_y
				lo := log_of_sum (log_z, log_x)
			elseif (log_z >= log_x) and (log_z >= log_y) then
				hi := log_z
				lo := log_of_sum (log_x, log_y)
			end

			Result := hi + log (1.0 + exp (lo - hi))
		end

	log_of_factorial (x: INTEGER): DOUBLE is
			-- Compute logarithm of (x!).
		require
			non_negative_x: x >= 0
		local
			k: INTEGER
		do
			if (x /= 0) and (x /= 1) then
				from k := 1 until k > x loop
					Result := Result + log (k)
					k := k + 1
				end
			end
		end

	log_of_combinatoric_factor (i, j: INTEGER): DOUBLE is
			-- Compute logarithm of (i! * j! / (i + j)!).
		local
			hi, lo, k: INTEGER
		do
			if i >= j then
				hi := i
				lo := j
			else
				hi := j
				lo := i
			end

			Result := 0.0 -- !
			from k := 1 until k > lo loop
				Result := Result + log (k) - log (hi + k) -- !
				k := k + 1
			end
		end

feature -- Global

	log_of_poisson_pdf (x: INTEGER; log_of_lambda: DOUBLE): DOUBLE is
			-- Logarithmic Poisson probability density function.
			-- Used as a default insertion distribution.
			-- http://en.wikipedia.org/wiki/Poisson_distribution
		do
			Result := log_of_lambda * x - exp (log_of_lambda) - log_of_factorial (x)
		end

end
