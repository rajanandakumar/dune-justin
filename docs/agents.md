# Agents

justIN uses agents to make periodic updates to the 
[justIN database](database.md). 

Each agent is implemented as a self-contained daemon written in Python 3. A
systemd service file provided for each agent, and each agent writes to a log 
file in /var/log/justin/ . 
For example, justin-finder's log file is /var/log/justin/finder .
 
- [justin-info-collector](agents.info_collector.md) - collects information about sites, storages, and users
- [justin-finder](agents.finder.md) - queries MetaCat for the list of files needed by a request and Rucio for the locations of each file's replicas
- justin-stage-cache - maintains the get_stage_cache and find_file_cache tables of currently optimal stages and unprocessed files for each site
- [justin-job-factory](agents.job_factory.md) - submits generic jobs with jobsub, which query the Workflow Allocator service to be allocated work
