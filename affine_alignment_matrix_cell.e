indexing
	description: "Matrix cell that holds affine alignment information."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	AFFINE_ALIGNMENT_MATRIX_CELL

create
	make_zero,
	make

feature -- Initialization

	make_zero is
			-- Initialize cell with zeros.
		do
		end

	make (a_m, a_ix, a_iy: DOUBLE) is
			-- Initialize cell with given score values.
		do
			m := a_m
			ix := a_ix
			iy := a_iy
		end

feature -- Access

	m: DOUBLE
			-- Score if previous operation was a matching (M).

	ix: DOUBLE
			-- Score if previous operation was an insertion on source sequence (Ix).

	iy: DOUBLE
			-- Score if previous operation was an insertion on target sequence (Iy).

	max: DOUBLE is
			-- max {m, ix, iy}.
		do
			if m >= ix then
				if m >= iy then
					Result := m
				else
					Result := iy
				end
			else
				if ix >= iy  then
					Result := ix
				else
					Result := iy
				end
			end
		end

feature -- Element change

	set_m (v: like m) is
			-- Let `m' be `v'.
		do
			m := v
		end

	set_ix (v: like ix) is
			-- Let `ix' be `v'.
		do
			ix := v
		end

	set_iy (v: DOUBLE) is
			-- Let `iy' be `v'.
		do
			iy := v
		end

end
