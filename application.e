indexing
	description: "BALIGN's root class."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	APPLICATION

inherit
	ISE_EXCEPTION_MANAGER

create
	make

feature -- Initialization

	op_source: AP_STRING_OPTION
	op_target: AP_STRING_OPTION
	op_score: AP_STRING_OPTION
	op_extra_columns: AP_FLAG
	op_alignment: AP_STRING_OPTION
	op_method: AP_STRING_OPTION
	op_gap_open: AP_STRING_OPTION
	op_gap_extension: AP_STRING_OPTION
	op_score_matrix: AP_STRING_OPTION
	op_secondary_source: AP_STRING_OPTION
	op_secondary_target: AP_STRING_OPTION
	op_secondary_score_matrix: AP_STRING_OPTION
	op_balance: AP_STRING_OPTION

	make is
			-- Run application.
		local
			ap: AP_PARSER
			failed: BOOLEAN
		do
			if not failed then
				create ap.make

				create op_source.make_with_short_form ('s')
				op_source.set_parameter_description ("SOURCE")
				op_source.set_description ("Read source sequences from SOURCE. Recognized file formats: FASTA.")
				op_source.enable_mandatory
				op_source.set_maximum_occurrences (1)
				ap.options.force_last (op_source)

				create op_target.make_with_short_form ('t')
				op_target.set_parameter_description ("TARGET")
				op_target.set_description ("Read target sequences from TARGET. Recognized file formats: FASTA. Default: SOURCE.")
				op_target.set_maximum_occurrences (1)
				ap.options.force_last (op_target)

				create op_score.make_with_short_form ('o')
				op_score.set_parameter_description ("OUTPUT")
				op_score.set_description ("Write scores into OUTPUT. There will be 5 columns for each sequence pair: index1 index2 length1 length2 score.")
				op_score.set_maximum_occurrences (1)
				ap.options.force_last (op_score)

				create op_extra_columns.make_with_short_form ('e')
				op_extra_columns.set_description ("Put 4 extra columns into OUTPUT for %%identity, %%similarity, %%gap and alignment length. This option triggers full alignment extraction and slows down the computation.")
				op_extra_columns.set_maximum_occurrences (1)
				ap.options.force_last (op_extra_columns)

				create op_alignment.make_with_short_form ('a')
				op_alignment.set_parameter_description ("ALIGNS")
				op_alignment.set_description ("Write alignments into ALIGNS. This option triggers full alignment extraction and slows down the computation.")
				op_alignment.set_maximum_occurrences (1)
				ap.options.force_last (op_alignment)

				create op_method.make_with_short_form ('m')
				op_method.set_parameter_description ("METHOD")
				op_method.set_description ("Align using METHOD. Default: NW. Available methods are NW (for Needleman-Wunch), SW (for Smith-Waterman) and OK (for Oommen-Kashyap). OK may take a very long time as it is an O(n^3) algorithm. Also remember that OK does not produce alignments and it needs special score matrices such as OPAM250 and OWALLQVIST.")
				op_method.set_maximum_occurrences (1)
				ap.options.force_last (op_method)

				create op_gap_open.make_with_short_form ('p')
				op_gap_open.set_parameter_description ("GAPOPEN")
				op_gap_open.set_description ("Set gap open penalty to GAPOPEN. Default: 10.0. OK algorithm ignores this option.")
				op_gap_open.set_maximum_occurrences (1)
				ap.options.force_last (op_gap_open)

				create op_gap_extension.make_with_short_form ('x')
				op_gap_extension.set_parameter_description ("GAPEXTEND")
				op_gap_extension.set_description ("Set gap extension penalty to GAPEXTEND. Default: 0.5. OK algorithm ignores this option.")
				op_gap_extension.set_maximum_occurrences (1)
				ap.options.force_last (op_gap_extension)

				create op_score_matrix.make_with_short_form ('i')
				op_score_matrix.set_parameter_description ("SCOREMAT")
				op_score_matrix.set_description ("Use score matrix SCOREMAT. Recognized file formats: BLAST score matrix. Default: BLOSUM62.")
				op_score_matrix.set_maximum_occurrences (1)
				ap.options.force_last (op_score_matrix)

				create op_secondary_source.make_with_short_form ('u')
				op_secondary_source.set_parameter_description ("SOURCE2")
				op_secondary_source.set_description ("Read secondary source sequences from SOURCE2. Recognized file formats: FASTA. This option triggers compound alignment.")
				op_secondary_source.set_maximum_occurrences (1)
				ap.options.force_last (op_secondary_source)

				create op_secondary_target.make_with_short_form ('r')
				op_secondary_target.set_parameter_description ("TARGET2")
				op_secondary_target.set_description ("Read secondary target sequences from TARGET2. Recognized file formats: FASTA. Default: SOURCE2 (only if TARGET is not specified). This option is ignored if SOURCE2 is not specified.")
				op_secondary_target.set_maximum_occurrences (1)
				ap.options.force_last (op_secondary_target)

				create op_secondary_score_matrix.make_with_short_form ('c')
				op_secondary_score_matrix.set_parameter_description ("SCOREMAT2")
				op_secondary_score_matrix.set_description ("Use secondary score matrix SCOREMAT2. Recognized file formats: BLAST score matrix. Default: WALLQVIST. This option is ignored if secondary sequences are not specified.")
				op_secondary_score_matrix.set_maximum_occurrences (1)
				ap.options.force_last (op_secondary_score_matrix)

				create op_balance.make_with_short_form ('b')
				op_balance.set_parameter_description ("BALANCE")
				op_balance.set_description ("Set primary/secondary balance to BALANCE. Default: 0.5. If 0, only primary sequences are considered. If 1, only secondary sequences are considered. This option is ignored if secondary sequences are not specified.")
				op_balance.set_maximum_occurrences (1)
				ap.options.force_last (op_balance)

				ap.set_parameters_description ("")
				ap.set_application_description ("Multi-functional batch sequence aligner by Eser Aygun (eser.aygun@gmail.com).")

				ap.parse_arguments

				is_compound := op_secondary_source.was_found
				if not is_compound then
					io.put_string ("Preparing for simple alignment...%N")
				else
					io.put_string ("Preparing for compound alignment...%N")
				end

				io.put_string ("Reading configuration and score matrices...%N")
				if not is_compound then
					read_simple_config
				else
					read_compound_config
				end

				io.put_string ("Reading sequences...%N")
				if not is_compound then
					read_simple_sequences
				else
					read_compound_sequences
				end

				io.put_string ("Working...%N")
				run

				io.put_string ("Done!%N")
			else
				io.put_string ("%NFatal error: " + last_exception.message + ".%N" +
					last_exception.meaning + "%N")
				if last_exception.message.starts_with ("negative_log_") then
					io.put_string ("Suggestion: If you are using OK method, ensure that the %
						%score matrices does not contain positive elements.%N")
				end
			end
		rescue
			failed := True
			retry
		end

feature {NONE} -- Implementation

	is_compound: BOOLEAN

	config: BALIGN_CONFIG [ANY]

	source_elements: CHARACTER_8_SET

	target_elements: CHARACTER_8_SET

	secondary_source_elements: CHARACTER_8_SET

	secondary_target_elements: CHARACTER_8_SET

	sources: ARRAYED_LIST [CHAIN [ANY]]

	targets: ARRAYED_LIST [CHAIN [ANY]]

	read_config (c: BALIGN_CONFIG [ANY]) is
			-- Read generic configuration.
		do
			if op_method.was_found then
				c.set_method (op_method.parameter)
			else
				c.set_method ("nw")
			end
			if op_gap_open.was_found and op_gap_open.parameter.is_double then
				c.set_gap_open_penalty (op_gap_open.parameter.to_double)
			else
				c.set_gap_open_penalty (10.0)
			end
			if op_gap_extension.was_found and op_gap_extension.parameter.is_double then
				c.set_gap_extension_penalty (op_gap_extension.parameter.to_double)
			else
				c.set_gap_extension_penalty (0.5)
			end
			if op_score_matrix.was_found then
				c.set_score_matrix (op_score_matrix.parameter)
			else
				c.set_score_matrix ("blosum62")
			end

			-- Create element sets from alphabets. Results will be used while reading
			-- sequences.
			create source_elements.make
			source_elements.merge (c.source_alphabet)
			create target_elements.make
			target_elements.merge (c.target_alphabet)
		end

	read_simple_config is
			-- Read and create simple alignment configuration.
		local
			c: BALIGN_SIMPLE_CONFIG
		do
			create c

			read_config (c)

			config := c
		end

	read_compound_config is
			-- Read and create compound alignment configuration.
		local
			c: BALIGN_COMPOUND_CONFIG
			ex: DEVELOPER_EXCEPTION
		do
			create c

			read_config (c)
			if op_target.was_found and not op_secondary_target.was_found then
				create ex
				ex.set_message ("Secondary target sequence file is not specified")
				ex.raise
			end
			if op_secondary_score_matrix.was_found then
				c.set_secondary_score_matrix (op_secondary_score_matrix.parameter)
			else
				c.set_secondary_score_matrix ("wallqvist")
			end
			if op_balance.was_found and op_balance.parameter.is_double then
				c.set_balance (op_balance.parameter.to_double)
			else
				c.set_balance (0.5)
			end

			-- Create element sets from alphabets. Results will be used while reading
			-- sequences.
			create secondary_source_elements.make
			secondary_source_elements.merge (c.secondary_source_alphabet)
			create secondary_target_elements.make
			secondary_target_elements.merge (c.secondary_target_alphabet)

			config := c
		end

	read_fasta (sequences: ARRAYED_LIST [CHAIN [CHARACTER]];
		file_name: STRING; elements: CHARACTER_8_SET) is
			-- Read FASTA file into a sequence list.
		local
			f: KL_TEXT_INPUT_FILE
			reader: FASTA_READER
			ex: DEVELOPER_EXCEPTION
		do
			create f.make (file_name)
			if f.exists then
				f.open_read

				create reader.make (f)
				reader.set_allowed_elements (elements)
				from
					reader.start
				until
					reader.off
				loop
					sequences.force (reader.item.to_chain)
					reader.forth
				end

				f.close
			else
				create {FILE_NOT_FOUND}ex
				ex.set_message (file_name)
				ex.raise
			end
		end

	read_simple_sequences is
			-- Read simple sequences.
		local
			sequences: ARRAYED_LIST [CHAIN [CHARACTER]]
		do
			create sequences.make (1)
			read_fasta (sequences, op_source.parameter, source_elements)
			sources := sequences

			if op_target.was_found then
				create sequences.make (1)
				read_fasta (sequences, op_target.parameter, target_elements)
				targets := sequences
			else
				targets := sources
			end
		end

	fuse_sequences (p, s: CHAIN [CHARACTER]): CHAIN [CHARACTER_PAIR] is
			-- Build a compound sequence from simple sequences `p' and `s'.
		require
			not_void: p /= Void and s /= Void
			same_length: p.count = s.count
		local
			i: INTEGER
			c: CHARACTER_PAIR
		do
			create {FIXED_LIST [CHARACTER_PAIR]}Result.make (p.count)
			from i := 1 until i > p.count loop
				create c.make (p [i], s [i])
				Result.extend (c)
				i := i + 1
			end
		end

	fuse_sequence_lists (p, s: ARRAYED_LIST [CHAIN [CHARACTER]]): ARRAYED_LIST [CHAIN [CHARACTER_PAIR]] is
			-- Build compound sequences from simple sequences.
		require
			not_void: p /= Void and s /= Void
			same_length: p.count = s.count
		local
			i: INTEGER
		do
			create Result.make (p.count)
			from i := 1 until i > p.count loop
				Result.extend (fuse_sequences (p [i], s [i]))
				i := i + 1
			end
		end

	read_compound_sequences is
			-- Read compound sequences.
		local
			primaries, secondaries: ARRAYED_LIST [CHAIN [CHARACTER]]
		do
			create primaries.make (1)
			read_fasta (primaries, op_source.parameter, source_elements)
			create secondaries.make (1)
			read_fasta (secondaries, op_secondary_source.parameter, secondary_source_elements)
			sources := fuse_sequence_lists (primaries, secondaries)

			if op_target.was_found then
				create primaries.make (1)
				read_fasta (primaries, op_target.parameter, target_elements)
				create secondaries.make (1)
				read_fasta (secondaries, op_secondary_target.parameter, secondary_target_elements)
				targets := fuse_sequence_lists (primaries, secondaries)
			else
				targets := sources
			end
		end

	run is
			-- Compare each source-target sequence pair.
		local
			score_file: KL_TEXT_OUTPUT_FILE
			alignment_file: KL_TEXT_OUTPUT_FILE
			rte: REMAINING_TIME_ESTIMATOR
			prev_elapsed_time: TIME_DURATION
			i, j: INTEGER
			row: STRING
		do
			if op_score.was_found then
				create score_file.make (op_score.parameter)
				score_file.open_write
			end
			if op_alignment.was_found then
				create alignment_file.make (op_alignment.parameter)
				alignment_file.open_write
			end
			if not op_score.was_found and not op_alignment.was_found then
				create score_file.make ("a.out")
				score_file.open_write
			end

			create rte.make (sources.count * targets.count)

			rte.start
			prev_elapsed_time := rte.elapsed_time.twin
			from i := 1 until i > sources.count loop
				from j := 1 until j > targets.count loop
					config.run (sources [i], targets [j])

					row := i.out + "%T" + j.out +
						"%T" + sources [i].count.out +
						"%T" + targets [j].count.out +
						"%T" + config.output.out

					if op_extra_columns.was_found or (alignment_file /= Void) then
						config.process_alignments(op_extra_columns.was_found,
							alignment_file /= Void)
						if op_extra_columns.was_found then
							row := row + "%T" + (config.best_identity * 100.0).rounded.out
							row := row + "%T" + (config.best_similarity * 100.0).rounded.out
							row := row + "%T" + (config.best_gap * 100.0).rounded.out
							row := row + "%T" + config.best_length.out
						end
						if alignment_file /= Void then
							alignment_file.put_line ("** " + i.out + ", " + j.out)
							alignment_file.put_line (config.detailed_output)
							alignment_file.put_new_line
						end
					end

					if score_file /= Void then
						score_file.put_line (row)
					end

					rte.next_job
					if (rte.elapsed_time - prev_elapsed_time).seconds_count >= 1 then
						prev_elapsed_time := rte.elapsed_time.twin
						io.put_string ("Last job done  : " + i.out + ", " + j.out + "%N")
						io.put_string ("Jobs per second: " + (1.0 / rte.seconds_per_job).out + "%N")
						io.put_string ("Time elapsed   : " +
							rte.elapsed_time.hour.out + "h " +
							rte.elapsed_time.minute.out + "m " +
							rte.elapsed_time.second.out + "s%N")
						io.put_string ("Time remaining : " +
							rte.remaining_time.hour.out + "h " +
							rte.remaining_time.minute.out + "m " +
							rte.remaining_time.second.out + "s%N")
						io.put_string ("--%N")
					end

					j := j + 1
				end

				i := i + 1
			end

			if score_file /= Void then
				score_file.close
			end
			if alignment_file /= Void then
				alignment_file.close
			end
		end

end
