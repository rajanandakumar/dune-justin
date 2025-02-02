## Files

The justIN workflow system keeps track of files within the context of a
request/stage. The same file may exist within multiple requests and stages
with different states according to how it has been processed within each
context. justIN's interfaces refer to files using Rucio DIDs 
(scope:name) and specifies the request and stage IDs too where necessary
to avoid ambiguity.

Lists of input files for the first stage of each request are normally 
discovered by the [Finder](finder.md) agent from MetaCat. (For Monte Carlo
requests the counter file names are generated by the Finder, and the Finder
can also obtain lists of file names in Rucio datasets directly from Rucio.)

Within the context of its request/stage, a file exists in one of the
following states:

- **finding** - the file is waiting for the Finder agent to discover the
  location(s) of its replica(s) from Rucio
- **unallocated** - the file's replica(s) are known and the file is waiting to
  be allocated to a job for processing
- **allocated** - the file has been allocated to a job for processing
- **outputting** - the job to which the file has been allocated is itself in the
  outputting state, and the job is registering any output files with MetaCat
  and Rucio and uploading them
- **processed** - the job to which the file has been allocated has successfully
  registered and uploaded any output files and reported the file as
  successfully processed
- **notfound** - the Finder agent failed to find any replicas for the file
- **failed** - processing of the file failed in some way
- **recorded** - the file is an output file created by a job which is in the
  the outputting state, but may not yet be registered in MetaCat and Rucio
  or uploaded to storage.
- **output** - the file is an output file created by a job, which will not be
  used as an input to the next stage of the request. It has been successfully 
  registered in MetaCat and Rucio and placed on storage. (Output files which 
  *will* be used as inputs to the next stage are placed in the finding state.)
