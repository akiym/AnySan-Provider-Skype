use inc::Module::Install;
use Module::Install::AuthorTests;
use Module::Install::Repository;

name 'AnySan-Provider-Skype';
all_from 'lib/AnySan/Provider/Skype.pm';

requires 'AnySan' => '0.08';
requires 'Skype::Any' => '0.01';

test_requires 'Test::More' => 0.98;

tests 't/*.t';
author_tests 'xt';

auto_set_repository;

WriteAll;
