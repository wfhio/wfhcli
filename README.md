# wfhcli

wfhcli is a CLI tool to query [WFH.io](https://www.wfh.io)'s JSON API.

## Usage Examples

List latest jobs:

```
wfhcli jobs
```

The above results are returned paged, with 30 jobs per page.  To view additional pages:

```
wfhcli jobs --page 2
```

List categories:

```
wfhcli categories
```

List job sources:

```
wfhcli sources
```

List jobs by category:

```
wfhcli jobs --category 3
```

List jobs by job source:

```
wfhcli jobs --source 2
```

List jobs by category and job source:

```
wfhcli jobs --category 3 --source 2
```

Show job details:

```
wfhcli job 994
```

List companies:

```
wfhcli companies
```

Similar to `wfhcli jobs`, you can also page through companies:

```
wfhcli companies --page 2
```

Show company details:

```
wfhcli company 536
```
