use Test;
use APS::Software;

plan 11;

my $*APSRELEASE = $*PROGRAM.sibling('releases').absolute.Str;

my $project = 'testproject';
my $name = 'testpge';
my $version = '1.0';
my $path = '/opt/testpge';
my $volume = "$*APSRELEASE/$project/$name/$version";
my $sw;

given APS::Software.new(:$project, item => 'testproject/testpge/1.0')
{
    is-deeply (.project, .name, .version, .path, .volume),
    ($project, $name, $version, $path, $volume), 'project/name/version';
}

given APS::Software.new(:$project, item => 'testpge/1.0')
{
    is-deeply (.project, .name, .version, .path, .volume),
    ($project, $name, $version, $path, $volume), 'name/version';
}

throws-like { APS::Software.new(:$project, item => 'testpge') },
    X::AdHoc, :message(/:s Must specify version/);

given APS::Software.new(:$project, item => %( name => 'testproject/testpge/1.0'))
{
    is-deeply (.project, .name, .version, .path, .volume),
    ($project, $name, $version, $path, $volume), 'project/name/version';
}

given APS::Software.new(:$project, item => %( name => 'testpge/1.0'))
{
    is-deeply (.project, .name, .version, .path, .volume),
    ($project, $name, $version, $path, .volume), 'name/version';
}

throws-like { APS::Software.new(:$project, item => %( name => 'testpge')) },
    X::AdHoc, :message(/:s Must specify version/);

given APS::Software.new(:$project, item => %( name => 'testpge/1.0',
                                         path => '/somewhere' ))
{
    is-deeply (.project, .name, .version, .path, .volume),
    ($project, $name, $version, '/somewhere', $volume), 'override path';
}

throws-like { APS::SoftwareList.new(:$project, list => <same/1.0 same/1.2>) },
    X::AdHoc, :message(/'Multiple definitions for /opt/same'/);

my @swlist =
    'testpge/1.0',                             # Gets default project

    'testproject/testpge2/1.0',                # project/name/version

    %( name => 'testproject/testpge3/1.0' ),   # project/name/version in hash

    %( name => 'testpge4/1.0'),                # name/version in hash

    %( project => 'testproject',               # Explicit hash
       name => 'testpge5',
       version => '1.0'),

    %( name => 'testpge6',                      # default project
       version => '1.0' ),

    %( name => 'testpge7/1.0',                  # specific path
       path => '/altpath' );

ok my $list = APS::SoftwareList.new(:$project, list => @swlist), 'Create list';

is-deeply $list.volumes,
     ('-v', "$*APSRELEASE/testproject/testpge/1.0:/opt/testpge:ro",
      '-v', "$*APSRELEASE/testproject/testpge2/1.0:/opt/testpge2:ro",
      '-v', "$*APSRELEASE/testproject/testpge3/1.0:/opt/testpge3:ro",
      '-v', "$*APSRELEASE/testproject/testpge4/1.0:/opt/testpge4:ro",
      '-v', "$*APSRELEASE/testproject/testpge5/1.0:/opt/testpge5:ro",
      '-v', "$*APSRELEASE/testproject/testpge6/1.0:/opt/testpge6:ro",
      '-v', "$*APSRELEASE/testproject/testpge7/1.0:/altpath:ro"), 'volumes';

is-deeply $list.env,
          ('-e', 'PATH=/opt/testpge/bin:/opt/testpge2/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
           '-e', 'PERL5LIB=/opt/testpge/lib/perl:/opt/testpge3/lib/perl:/usr/local/lib/perl'), 'Environment';

done-testing;
