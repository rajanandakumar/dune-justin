# justin command man page
This man page is distributed along with the 
[justin command](justin_command.md) itself.

    JUSTIN(2023)							  JUSTIN(2023)
    
    NAME
           justin - justIN workflow system utility command
    
    SYNOPSIS
           justin subcommand [options]
    
    DESCRIPTION
           justin is a command-line utility for managing requests, stages, files,
           and replicas in the justIN workflow system.
    
    
    GENERAL OPTIONS
           -h, --help
    	      Show help message and exit
    
    
           -v, --verbose
    	      Turn on verbose logging of the communication with justIN
    	      service.
    
    
           --url URL
    	      Use an alternative justIN service, rather than https://justin-
    	      ui-pro.dune.hep.ac.uk/api/commands This option is only needed
    	      during development and testing.
    
    
    SUBCOMMANDS
           version
    	      Output the version number of the justin command.
    
    
           time   Contact justIN to get the current time as a string. This can be
    	      used to check that the client is installed correctly and that
    	      the user is properly registered in justIN.
    
    
           whoami
    	      Displays information about the current user identity and
    	      session.
    
    
           create-request [--description DESC] [--mql QUERY|--monte-carlo COUNT]
    	      [--scope SCOPE] [--refind-start-date YYYYMMDD]
    	      [--refind-duration-days DAYS] [--refind-interval-hours HOURS]
    	      Create a new, empty request in the database, optionally with the
    	      given short, human-readable description and either a MetaCat
    	      Query Language expression or the count of the number of Monte
    	      Carlo instances to run.
    
    	      --scope SCOPE specifies the Rucio scope used for any output
    	      files to be registered with Rucio and uploaded to Rucio-managed
    	      storage.
    
    	      Requests are created in the state "draft" and the command
    	      returns the new request's ID number.  Once the request is in the
    	      running state, justIN will use the MQL expression to find the
    	      list of input files from MetaCat. If --refind-interval-hours is
    	      given, the MQL query will be resubmitted at that interval to add
    	      any new matching files from the start of the day given by
    	      --refind-start-date (default: today in UTC) for the number of
    	      days given by --refind-duration-days (default: 1).
    
    
           show-requests [--request-id ID]
    	      Show details of all requests or optionally of a single request.
    	      Each line of the output gives the request ID, state, creation
    	      time, description, and MetaCat query of one request.
    
    
           submit-request --request-id ID
    	      Changes the state of the given request from "draft" to
    	      "submitted". The justIN Finder agent will automatically set the
    	      request to running after any necessary initialisation.
    
    
           restart-request --request-id ID
    	      Restarts a request in the "paused" stated, and changes its state
    	      to "running".
    
    
           pause-request --request-id ID
    	      Changes the state of the given running request to "paused". This
    	      state temporarily excludes a request from the workflow
    	      allocation process.
    
    
           finish-request --request-id ID
    	      Changes the state of the given running request to "finished".
    	      This state excludes a request from the workflow allocation
    	      process.
    
    
           create-stage --request-id ID --stage-id ID  --jobscript
    	      FILENAME|--jobscript-id JSID [--wall-seconds N] [--rss-mb N]
    	      [--processors N] [--max-distance DIST] [--output-pattern
    	      PATTERN:DESTINATION] [--output-pattern-next-stage
    	      PATTERN:DATASET] [--output-rse NAME] [--lifetime-days DAYS]
    	      [--env NAME=VALUE]
    	      Creates a new stage for the given request ID with the given
    	      stage ID. Stages must be numbered consecutively from 1, and each
    	      request must have at least one stage.
    
    	      Each stage must have a jobscript shell script associated with
    	      it, given by the --jobscript or --jobscript-id options.  Either
    	      the full, local path to the jobscript file is given, or the
    	      jobscript is taken from justIN's Jobscripts Library using a JSID
    	      jobscript identifier.  The JSID is in the form SCOPE:NAME or
    	      USER:NAME, where USER includes an '@' character. In either case,
    	      a copy of the current text of the jobscript is cached in the
    	      stage definition and executed on worker nodes to process the
    	      stage's files.
    
    	      If the maximum wallclock time needed is not given by
    	      --wall-seconds then the default of 80000 seconds is used. If the
    	      maximum amount of resident memory needed is not given by
    	      --rss-mb then the default of 2000MiB is used. The resident
    	      memory corresponds to the physical memory managed by HTCondor's
    	      ResidentSetSize value.
    
    	      If the script can make use of multiple processors then
    	      --processors can be used to give the number needed, with a
    	      default of 1 if not given.
    
    	      By default, input files will only be allocated to a script which
    	      are on storages at the same site (distance=0). This can be
    	      changed by setting --max-distance DIST to allow input files to
    	      be allocated on storages at greater distances, up to a value of
    	      100 which represents maximally remote storages.
    
    	      If one or more options --output-pattern PATTERN:DESTINATION is
    	      given then the generic job will look for files created by the
    	      script which match the pattern given as PATTERN. The pattern is
    	      a Bash shell pattern using *, ? and [...] expressions. See the
    	      bash(1) Pattern Matching section for details.  If the given
    	      DESTINATION starts with https:// then the matching output files
    	      will be uploaded to WebDAV scratch space, such as dCache at
    	      Fermilab. The DESTINATION must be the URL of a directory
    	      accessible via WebDAV, and given with or without a trailing
    	      slash. Nested subdirectories for request ID and stage ID will be
    	      added, and resulting output files placed there. The user's token
    	      from the justIN dashboard is used for the upload.  If an
    	      https:// URL is not given, DESTINATION is interpreted as an
    	      existing Rucio dataset minus the scope component. The overall
    	      scope of the request is used and the output files are uploaded
    	      with Rucio and registered in that dataset. Furthermore, files
    	      for Rucio-managed storage must have a corresponding JSON
    	      metadata file with the same name but with ".json" appended, that
    	      will be recorded for that file in MetaCat.
    
    	      Alternatively --output-pattern-next-stage PATTERN:DATASET can be
    	      given in which case the output file will be uploaded to Rucio-
    	      managed storage and will also be registered in the justIN
    	      Database as an unprocessed input file for the next stage and
    	      available for allocation to instances of that stage's script.
    
    	      If one or more options --output-rse NAME is given, then the RSE
    	      used for uploads of output files will be chosen from that list
    	      of RSEs, with preference given to RSEs which are closer in
    	      distance. If this option is not used, or none of the given RSEs
    	      are available, then the default algorithm for choosing the
    	      closest available RSE is used.
    
    	      --lifetime-days DAYS sets the Rucio lifetime for all output
    	      files that are uploaded. The lifetime defaults to 1 day if not
    	      specified.
    
    	      --env NAME=VALUE can be used one or more times to set
    	      environment variables when the stage's jobscript is executed.
    
    
           quick-request [--description DESC] [--mql QUERY|--monte-carlo COUNT]
    	      [--scope SCOPE] [--refind-start-date YYYYMMDD]
    	      [--refind-duration-days DAYS] [--refind-interval-hours HOURS]
    	      --jobscript FILENAME|--jobscript-id JSID [--wall-seconds N]
    	      [--rss-mb N] [--processors N] [--max-distance DIST]
    	      [--output-pattern PATTERN:DESTINATION] [--output-rse NAME]
    	      [--lifetime-days DAYS] [--env NAME=VALUE]
    	      Combines the create-request, create-stage and submit-request
    	      subcommands into a single operation, for use with single-stage
    	      requests. The options are repeated from the first two
    	      subcommands and are described in their respective sections
    	      above.
    
    
           show-stages --request-id ID [--stage-id ID]
    	      Shows details of all stages of the given request or optionally
    	      of a single stage of that request. Each line of the output gives
    	      the request ID, stage ID,, min processors, max processors, max
    	      wallclock seconds, max RSS bytes, and the max distance value.
    
    
           create-jobscript [--description DESC] [--scope SCOPE] --name NAME
    	      --jobscript FILENAME
    	      Creates a named jobscript in the Jobscripts Library, with an
    	      optional description. The jobscript is created with the
    	      specified scope if one is given. Otherwise the jobscript is
    	      created under your user name. The jobscript identifier is
    	      returned on success, in the form SCOPE:NAME or USER:NAME.
    	      Jobscript names must be unique for each scope or user name. If a
    	      jobscript already exists for the given scope or user name it is
    	      overwritten.
    
           show-jobscript --jobscript-id JSID
           show-jobscript --request-id ID --stage-id ID
    	      Show a jobscript, referenced either by a jobscript identifier or
    	      by request and stage. If an identifier is given, the jobscript
    	      is taken from the Jobscripts Library. The JSID identifier
    	      consists of USER:NAME or SCOPE:NAME, where NAME is the jobscript
    	      name, USER is the user name of any user and contains an '@'
    	      character, and SCOPE is a Rucio scope name known to justIN.
    	      Alternatively, if request and stage are given, then the
    	      jobscript cached for that request and stage is shown.
    
           show-stage-outputs --request-id ID --stage-id ID
    	      Shows the datasets to be assigned and the patterns used to find
    	      output files of the given stage within the given request. Each
    	      line of the response consists of "(next)" or "(  )" depending on
    	      whether the files are passed to the next stage within the
    	      request, and then the scope, files pattern, and destination.
    
    
           fail-files --request-id ID [--stage-id ID]
    	      Set all the files of the given request, and optionally stage, to
    	      the failed state when they are already in the finding,
    	      unallocated, allocated, or outputting state. Files in the
    	      processed, failed, or notfound states are unchanged. This allows
    	      requests with a handful of pathological files to be terminated,
    	      as the Finder agent will see all the files are now in terminal
    	      states and mark the request as finished.
    
           show-files --request-id ID [--stage-id ID] [--file-did DID]
           show-files --mql QUERY
    	      Show up to 100 files either cached in the justIN Database and
    	      filtered by request ID and optionally by stage ID and/or file
    	      DID; or found by a query to MetaCat using the given MQL query.
    
           show-replicas --request-id ID [--stage-id ID] [--file-did DID]
           show-replicas --mql QUERY
    	      Show up to 100 replicas either cached in the justIN Database and
    	      filtered by request ID and optionally by stage ID and/or file
    	      DID; or found by a query to MetaCat using the given MQL query
    	      and looked up using Rucio.
    
           show-jobs --jobsub-id ID | --request-id ID [--stage-id ID] [--state
    	      STATE]
    	      Show jobs identified by Jobsub ID or Request ID (and optionally
    	      Stage ID). Job state can also be given to further filter the
    	      jobs listed. For each job, the Jobsub ID, Request ID, Stage ID,
    	      State, and creation time are shown.
    
    
    JOBSCRIPTS
           The user jobscripts supplied when creating a stage are shell scripts
           which the generic jobs execute on the worker nodes matched to that
           stage.  They are started in an empty workspace directory.  Several
           environment variables are made available to the scripts, all prefixed
           with JUSTIN_, including $JUSTIN_REQUEST_ID, $JUSTIN_STAGE_ID and
           $JUSTIN_SECRET which allows the jobscript to authenticate to justIN's
           allocator service. $JUSTIN_PATH is used to reference files and scripts
           provided by justIN.
    
           To get the details of an input file to work on, the command
           $JUSTIN_PATH/justin-get-file is executed by the jobscript.  This
           produces a single line of output with the Rucio DID of the chosen file,
           its PFN on the optimal RSE, and the name of that RSE, all separated by
           spaces. This code fragment shows how the DID, PFN and RSE can be put
           into shell variables:
    
    	 did_pfn_rse=`$JUSTIN_PATH/justin-get-file`
    	 did=`echo $did_pfn_rse | cut -f1 -d' '`
    	 pfn=`echo $did_pfn_rse | cut -f2 -d' '`
    	 rse=`echo $did_pfn_rse | cut -f3 -d' '`
    
           If no file is available to be processed, then justin-get-file produces
           no output to stdout, which should also be checked for. justin-get-file
           logs errors to stderr.
    
           justin-get-file can be called multiple times to process more than one
           file in the same jobscript. This can be done all at the start or
           repeatedly during the lifetime of the job. justin-get-file is itself a
           simple wrapper around the curl command and it would also be possible to
           access the justIN allocator service's REST API directly from an
           application.
    
           Each file returned by justin-get-file is marked as allocated and will
           not be processed by any other jobs. When the jobscript finishes, it
           must leave files with lists of the processed files in its workspace
           directory. These lists are sent to the justIN allocator service by the
           generic job, which either marks input files as being successfully
           processed or resets their state to unallocated, ready for matching by
           another job.
    
           Files can be referred to either by DID or PFN, one per line, in the
           appropriate list file:
    	 justin-processed-dids.txt
    	 justin-processed-pfns.txt
    
           It is not necessary to create list files which would otherwise be
           empty. You can use a mix of DIDs and PFNs, as long as each appears in
           the correct list file. Any files not represented in either file will be
           treated as unprocessed and made available for other jobs to process.
    
           Output files which are to be uploaded with Rucio by the generic job
           must be created in the jobscript's workspace directory and have
           filenames matching the patterns given by --output-pattern or
           --output-pattern-next-stage when the stage was created. The suffixed
           .json is appended to find the corresponding metadata files for MetaCat.
    
    
    REQUEST PROCESSING
           Once a request enters the running state, it is processed by justIN's
           Finder agent to find its input files. Usually this is just done once,
           but it can be repeated if the --refind-interval-hours option is given
           when creating the request. When the request is processed, the finder
           uses the requests's MQL expression to create a list of input files for
           the first stage. Work is only assigned to jobs when a matching file is
           found and so these lists of files are essential.
    
           In most cases, the MQL query is a MetaCat Query Language expression,
           which the Finder sends to the MetaCat service to get a list of matching
           file DIDs.  However, if the query is of the form "rucio-dataset
           SCOPE:NAME" then the query is sent directly to Rucio to get the list of
           file DIDs contained in the given Rucio dataset. Finally if the
           --monte-carlo COUNT option is used when creating the request, then an
           MQL of the form "monte-carlo COUNT" is stored. This causes the Finder
           itself to create a series of COUNT placeholder files which can be used
           to keep track of Monte Carlo processing without a distinct input file
           for each of the COUNT jobs.  Each of these placeholder files has a DID
           of the form monte-carlo-REQUEST_ID-NUMBER where NUMBER is in the range
           1 to COUNT, and REQUEST_ID is the assigned request ID number.
    
    
    AUTHENTICATION AND AUTHORIZATION
           When first used on a given computer, the justin command contacts the
           central justIN services and obtains a session ID and secret which are
           placed in a temporary file. You will then be invited to visit a web
           page on the justIN dashboard which has instructions on how to authorize
           that session, using CILogon and your identity provider. Once
           authorized, you can use the justin command on that computer for 7 days,
           and then you will be invited to re-authorize it. You can have multiple
           computers at multiple sites authorized at the same time.
    
    
    FILES
           A session file /var/tmp/justin.session.USERID is created by justin,
           where USERID is the numeric Unix user id, given by id -u
    
    
    AUTHOR
           Andrew McNab <Andrew.McNab@cern.ch>
    
    
    SEE ALSO
           bash(1)
    
    justIN Manual			    justin			  JUSTIN(2023)
