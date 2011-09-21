This is an attempt to clean the peaklist files from HMDB for easier
machine parsing.  Looking over them, there is obviously a large amount
of hand-editing that went into creating them - this led to many
inconsistencies.  This project attempts to fix some of those
inconsistencies by MORE hand-editing.

RadixSeven is mainly interested in getting HNMR peaklists.  So he will
just clean that section of the files.  However other contributors are
welcome to do pull requests for the rest.

No data is to be added to the files.  You cannot infer a missing
peaklist from the multiplet list, for example.

#Branch Structure

* master: the current production version - Any commits must pass all the
  automated tests.

* hmdb: mirrors the latest HMDB - updated when someone downloads
  latest and makes a new commit

* anything_else: feature branch - branches off master to make specific
  cleaning and/or add more tests.

#License text from HMDB

HMDB is offered to the public as a freely available resource. Use and re-distribution of the data, in whole or in part, for commercial purposes requires explicit permission of the authors and explicit acknowledgment of the source material (HMDB) and the original publication (see below). We ask that users who download significant portions of the database cite the HMDB paper in any resulting publications.

* Wishart DS, Knox C, Guo AC, et al. [HMDB: a knowledgebase for the human metabolome](http://www.ncbi.nlm.nih.gov/pubmed/18953024). Nucleic Acids Res. 2009 37(Database issue):D603-610.


