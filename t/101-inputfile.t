use Test;
use APS::InputFile;

plan 10;

my $*APSROOT = $*PROGRAM.sibling('tis').absolute.Str;

my $project = 'testproject';
my $project2 = 'testproject2';
my $filename = 'file1';
my $filename2 = 'file2';
my $volume = "$*APSROOT/$project/data/$filename";
my $volume2 = "$*APSROOT/$project2/data/$filename2";

given APS::InputFile.new(:$project, item => $filename)
{
    is-deeply (.project, .filename, .volume),
    ($project, $filename, $volume), 'filename';
}

given APS::InputFile.new(:$project, item => "testproject/file1")
{
    is-deeply (.project, .filename, .volume),
    ($project, $filename, $volume), 'project/filename';
}

given APS::InputFile.new(:$project, item => "/testproject/file1")
{
    is-deeply (.project, .filename, .volume),
    ($project, $filename, $volume), 'project/filename';
}

given APS::InputFile.new(:$project, item => filename => "file1" )
{
    is-deeply (.project, .filename, .volume),
    ($project, $filename, $volume), 'hash filename';
}

given APS::InputFile.new(:$project, item => filename => "testproject/file1" )
{
    is-deeply (.project, .filename, .volume),
    ($project, $filename, $volume), 'hash filename';
}

given APS::InputFile.new(:$project, item => %( project => $project2,
                                     filename => $filename2) )
{
    is-deeply (.project, .filename, .volume),
    ($project2, $filename2, $volume2), 'hash project + filename';
}

my @list = <file1 testproject/file2>;

ok my $list = APS::InputFileList.new(:$project, :@list), 'list 1';

is-deeply $list.volumes,
          (
              '-v', "$*APSROOT/testproject/data/file1:/home/aps/input/file1:ro",
              '-v', "$*APSROOT/testproject/data/file2:/home/aps/input/file2:ro"
          ), 'volumes 1';

@list = 'file1', '/testproject/file3',
        %( project => 'testproject2', filename => 'file2');

ok $list = APS::InputFileList.new(:$project, :@list), 'list2';

is-deeply $list.volumes,
          (
            '-v', "$*APSROOT/testproject/data/file1:/home/aps/input/file1:ro",
            '-v', "$*APSROOT/testproject/data/file3:/home/aps/input/file3:ro",
            '-v', "$*APSROOT/testproject2/data/file2:/home/aps/input/file2:ro"
          ), 'volumes 2';

done-testing;
