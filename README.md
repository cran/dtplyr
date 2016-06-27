# dtplyr

[![Travis-CI Build Status](https://travis-ci.org/hadley/dtplyr.svg?branch=master)](https://travis-ci.org/hadley/dtplyr)
[![Coverage Status](https://img.shields.io/codecov/c/github/hadley/dtplyr/master.svg)](https://codecov.io/github/hadley/dtplyr?branch=master)

dtplyr is the data.table backend for dplyr. It provides S3 methods for data.table objects so that dplyr works the way you expect. 

dtplyr will always be a bit slower than data.table, because it creates copies of objects rather than mutating in place (that's the dplyr philosophy). Currently, dtplyr is quite a lot slower than bare data.table because the methods aren't quite smart enough. I hope interested dplyr & data.table users from the community will help me to improve the performance.

dtplyr was extracted out of dplyr so it could evolve independently (i.e. more rapidly!) than dplyr. It also makes dplyr a little simpler, and it's easier to keep track of issues by backend.

## Installation

You can install from Github with:

```R
# install.packages("devtools")
devtools::install_github("hadley/dtplyr")
```
