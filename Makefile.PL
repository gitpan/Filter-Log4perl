#!/usr/bin/env perl

use 5.8.1;
use strict;
use warnings;

use inc::Module::Install;


name('Filter-Log4perl');
all_from('lib/Filter/Log4perl.pm');

build_requires('Module::Install');
build_requires('Test::Base');

requires('version');
requires('Data::Dump');
requires('Filter::Simple');
requires('Log::Log4perl');
requires('PPI');
requires('Regexp::Common');

auto_include();
auto_install();

WriteAll();
