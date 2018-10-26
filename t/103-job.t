use Test;
use APS::Job;

plan 12;

my $*APSROOT = '/tis';
my $*APSRELEASE = "$*APSROOT/rel";

my regex uuid  { <xdigit> ** 8 '-' (<xdigit> ** 4 '-') ** 3 <xdigit> ** 12 };

my $TESTDIR = $*PROGRAM.parent;

my @jobs = parsejobs($TESTDIR.add('test.jobfile').Str);

is @jobs.elems, 1, 'Number of jobs';

with @jobs[0]
{
    like .runid, /^<uuid>$/, 'runid set';

    is .yaml, $TESTDIR.add('test.jobfile').slurp, 'yaml is right';

    is .project, 'testproject', 'project';

    is .archiveset, 'testarchiveset', 'archiveset';

    is .image, 'tisaps/testimage:1.0', 'image';

    is .command, '/opt/runapp/bin/entrypoint.sh', 'command';

    is-deeply .args, [<a b c>], 'args';

    is-deeply .software.hashlist,
        ({:name("testpge"), :project("testproject"), :version("1.0")},
         {:name("testpge"), :project("testproject"), :version("1.1")},
         {:name("testpge"), :project("testproject"), :version("1.2")}),
    'Software hashlist';

    is-deeply .software.volumes,
        ("-v", "/tis/rel/testproject/testpge/1.0:/opt/testpge:ro",
         "-v", "/tis/rel/testproject/testpge/1.1:/test/pge/testpge-1.1:ro",
         "-v", "/tis/rel/testproject/testpge/1.2:/mnt/pge:ro"),
    'Software volumes';

    is-deeply .inputs.hashlist,
        ({:filename("testfile1"), :project("testproject")},
         {:filename("testfile2"), :project("testproject")},
         {:filename("testfile3"), :project("testproject")}),
    'Inputs hashlist';

    is-deeply .inputs.volumes,
        ("-v", "/tis/testproject/data/testfile1:/home/aps/input/testfile1:ro",
         "-v", "/tis/testproject/data/testfile2:/home/aps/input/testfile2:ro",
         "-v", "/tis/testproject/data/testfile3:/home/aps/input/testfile3:ro"),
    'Inputs volumes';

    say .Str;
}

done-testing;
