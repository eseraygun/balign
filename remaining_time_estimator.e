indexing
	description: "Estimates remaining time."
	author: "Eser Aygün"
	date: "$Date$"
	revision: "$Revision$"

class
	REMAINING_TIME_ESTIMATOR

inherit
	TIME_CONSTANTS

	DOUBLE_MATH

create
	make

feature {NONE} -- Initialization

	make (n: INTEGER) is
			-- Initialize estimator for `n' jobs.
		do
			job_count := n
		end

feature -- Access

	job_count: INTEGER
			-- Number of total jobs.

	completed_job_count: INTEGER
			-- Number of completed jobs.

	remaining_job_count: INTEGER is
			-- Number of remaining jobs.
		do
			Result := job_count - completed_job_count
		end

feature -- Measurement

	elapsed_time: TIME_DURATION
			-- Elapsed time.

	remaining_time: TIME_DURATION
			-- Remaining time.

	seconds_per_job: DOUBLE
			-- Fine seconds per job.

feature -- Status report

feature -- Status setting

feature -- Cursor movement

feature -- Element change

feature -- Removal

feature -- Resizing

feature -- Transformation

feature -- Conversion

feature -- Duplication

feature -- Miscellaneous

feature -- Basic operations

	start is
			-- Start keeping time.
		do
			create elapsed_time.make_by_seconds (0)
			create start_time.make_now
			create last_time.make_now
		end

	next_job is
			-- Finish current job and move on to next.
		local
			elapsed_date_time: DATE_TIME_DURATION
			remaining_seconds: DOUBLE
		do
			completed_job_count := completed_job_count + 1
			create last_time.make_now

			-- Compute elapsed time.
			elapsed_date_time ?= (last_time - start_time).duration
			check
				not_void: elapsed_date_time /= Void
			end
			elapsed_date_time := elapsed_date_time.to_canonical (start_time)
			elapsed_date_time.set_origin_date_time (start_time)
			create elapsed_time.make_by_fine_seconds (elapsed_date_time.fine_seconds_count)
			elapsed_time := elapsed_time.to_canonical

			-- Compute seconds per job.
			seconds_per_job := elapsed_time.fine_seconds_count / completed_job_count

			-- Compute remaining time.
			remaining_seconds := seconds_per_job * remaining_job_count
			create remaining_time.make_by_fine_seconds (remaining_seconds)
			remaining_time := remaining_time.to_canonical
		end

feature -- Obsolete

feature -- Inapplicable

feature {NONE} -- Implementation

	start_time: DATE_TIME
			-- Starting time of estimation.

	last_time: DATE_TIME
			-- Time of last job completion.

invariant
	completed_smaller_than_total: completed_job_count <= job_count

end
