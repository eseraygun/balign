note
	description: "Generic BALIGN configuration."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	BALIGN_CONFIG [G]

inherit
	BLAST_SCORE_MATRICES

feature -- Access

	comparer: SEQUENCE_COMPARER [G, G]
			-- Comparer object.

	source_alphabet: ARRAYED_LIST [CHARACTER]
			-- Alphabet of source sequences.

	target_alphabet: ARRAYED_LIST [CHARACTER]
			-- Alphabet of target sequences.

	score_matrix: ARRAY2 [like output]
			-- Score matrix.

	output: DOUBLE
			-- Result.

	best_length: INTEGER
			-- Length of the best of the best alignment.

	best_identity: DOUBLE
			-- Identity ratio of the best of the best alignment.

	best_similarity: DOUBLE
			-- Similarity ratio of the best of the best alignment.

	best_gap: DOUBLE
			-- Gap ratio of the best of the best alignment.

	detailed_output: STRING
			-- Detailed output for every best alignments.

feature -- Measurement

feature -- Status report

feature -- Status setting

feature -- Cursor movement

feature -- Element change

	set_method (v: STRING) is
			-- Create comparer corresponding to string `v'.
		require
			not_void: v /= Void
		local
			ex: DEVELOPER_EXCEPTION
		do
			comparer := Void

			if v.as_lower.is_equal ("nw") then
				create {AFFINE_GLOBAL_ALIGNER [G, G]}comparer.make
			elseif v.as_lower.is_equal ("sw") then
				create {AFFINE_LOCAL_ALIGNER [G, G]}comparer.make
			elseif v.as_lower.is_equal ("ok") then
				create {LOG_OOMMEN_PROBABILITY [G, G]}comparer.make
			else
				create {UNDEFINED_VALUE}ex
				ex.set_message (v)
				ex.raise
			end
		ensure
			comparer_created: comparer /= Void
		end

	set_score_matrix (v: STRING) is
			-- Create score matrix corresponding to string `v'.
		require
			not_void: v /= Void
		local
			f: KL_TEXT_INPUT_FILE
			s: KL_STRING_INPUT_STREAM
			reader: BLAST_SCORE_MATRIX_READER
			oommen: LOG_OOMMEN_PROBABILITY [CHARACTER, CHARACTER]
			log_of_lambda: DOUBLE
			ex: DEVELOPER_EXCEPTION
		do
			score_matrix := Void

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

			score_matrix := reader.item
			source_alphabet := reader.source_alphabet
			target_alphabet := reader.target_alphabet

			set_gaps
			comparer.set_score_matrix (agent score_matrix_function)

			oommen ?= comparer
			if oommen /= Void then
				log_of_lambda := oommen.score_matrix.item ([oommen.source_gap, oommen.target_gap])
				oommen.set_insertion_distribution (agent oommen.log_of_poisson_pdf (?, log_of_lambda))
			end
		ensure
			score_matrix_created: score_matrix /= Void
		end

	set_gap_open_penalty (v: REAL) is
			-- Let gap opening penalty be `v'.
		local
			aligner: AFFINE_ALIGNER [G, G]
		do
			aligner ?= comparer
			if aligner /= Void then
				aligner.set_gap_open_penalty (v)
			end
		end

	set_gap_extension_penalty (v: REAL) is
			-- Let gap extension penalty be `v'.
		local
			aligner: AFFINE_ALIGNER [G, G]
		do
			aligner ?= comparer
			if aligner /= Void then
				aligner.set_gap_extension_penalty (v)
			end
		end

feature -- Removal

feature -- Resizing

feature -- Transformation

feature -- Conversion

feature -- Duplication

feature -- Miscellaneous

feature -- Basic operations

	run (source, target: CHAIN [G]) is
			-- Carry out job for sequences `source' and `target'.
		do
			comparer.set_source (source)
			comparer.set_target (target)
			comparer.run
			output := comparer.output
		end

	proce is
			-- Generate best_identity and other statistics.
		local
			aligner: SEQUENCE_ALIGNER [G, G]
			alignment: ALIGNMENT [G, G]
			identity_ratio: DOUBLE
			similarity_ratio: DOUBLE
			gap_ratio: DOUBLE
		do
			best_length := 0
			best_identity := 0.0
			best_similarity := 0.0
			best_gap :=1.0

			aligner ?= comparer
			if aligner /= Void then
				aligner.find_best_alignments
				from
					aligner.best_alignments.start
					detailed_output := ""
				until
					aligner.best_alignments.off
				loop
					alignment := aligner.best_alignments.item

					identity_ratio := alignment.identity / alignment.count
					similarity_ratio := alignment.similarity / alignment.count
					gap_ratio := alignment.gaps / alignment.count
					if (identity_ratio > best_identity) or else
					   (similarity_ratio > best_similarity) or else
					   (gap_ratio < best_gap) or else
					   (alignment.count > best_length) then
					   	best_length := alignment.count
					   	best_identity := identity_ratio
					   	best_similarity := similarity_ratio
					   	best_gap := gap_ratio
					end

					aligner.best_alignments.forth
				end
			end
		end

	process_alignments(generate_stats, generate_details: BOOLEAN) is
			-- Process alignments and generate detailed output when asked.
		local
			aligner: SEQUENCE_ALIGNER [G, G]
			alignment: ALIGNMENT [G, G]
			identity_ratio: DOUBLE
			similarity_ratio: DOUBLE
			gap_ratio: DOUBLE
		do
			best_length := 0
			best_identity := 0.0
			best_similarity := 0.0
			best_gap :=1.0
			detailed_output := ""

			aligner ?= comparer
			if aligner /= Void then
				aligner.find_best_alignments
				from
					aligner.best_alignments.start
					detailed_output := ""
				until
					aligner.best_alignments.off
				loop
					alignment := aligner.best_alignments.item

					if generate_stats then
						identity_ratio := alignment.identity / alignment.count
						similarity_ratio := alignment.similarity / alignment.count
						gap_ratio := alignment.gaps / alignment.count
						if (identity_ratio > best_identity) or else
						   (similarity_ratio > best_similarity) or else
						   (gap_ratio < best_gap) or else
						   (alignment.count > best_length) then
						   	best_length := alignment.count
						   	best_identity := identity_ratio
						   	best_similarity := similarity_ratio
						   	best_gap := gap_ratio
						end
					end

					if generate_details then
						detailed_output := detailed_output +
							"* " +
							alignment.source_start.out + "-" +
							alignment.source_end.out + " / " +
							alignment.target_start.out + "-" +
							alignment.target_end.out + ", " +
							"Length: " + alignment.count.out + ", " +
							"Score: " + alignment.score.out + ", " +
							"Identity: " + alignment.identity.out + ", " +
							"Similarity: " + alignment.similarity.out + ", " +
							"Gaps: " + alignment.gaps.out + "%N"
						detailed_output := detailed_output +
							chain_to_string (alignment.aligned_source) + "%N"
						detailed_output := detailed_output +
							chain_to_string (alignment.aligned_target)
					end

					aligner.best_alignments.forth
				end
			else
				if generate_details then
					detailed_output := "* Score: " + comparer.output.out
				end
			end
		end

feature -- Obsolete

feature -- Inapplicable

feature {NONE} -- Implementation

	set_gaps is
			-- Set comparer gaps.
		deferred
		end

	score_matrix_function (s, t: G): DOUBLE is
			-- Return score matrix entry for elements `s' and `t'.
		deferred
		end

	chain_to_string (c: CHAIN [G]): STRING is
			-- Convert element chain `c' to a string.
		require
			not_null: c /= Void
		deferred
		ensure
			not_null: Result /= Void
		end

end
