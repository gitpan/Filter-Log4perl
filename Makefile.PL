#!/usr/bin/env perl

use 5.8.1;
use strict;
use warnings;

use inc::Module::Install;


name('Filter-Log4perl');
all_from('lib/Filter/Log4perl.pm');


auto_include();
auto_install();

WriteAll();
