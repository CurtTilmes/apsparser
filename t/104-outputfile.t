use Test;
use APS::OutputFile;

my $TESTDIR = $*PROGRAM.parent;

plan 1;

my $project = 'testproject';
my $archiveset = 'testarchiveset';
my $dir = $TESTDIR.add('output').Str;

my $outfiles = APS::OutputFileList.new(:$project, :$archiveset, :$dir);

is-deeply $outfiles.hashlist,
    ({:archiveset("testarchiveset"),
      :datatime("2018-10-01 01:45"),
      :esdt("testesdt"),
      :filename("testfile4"),
      :filesize(21),
      :key("2018-10-01 01:45"),
      :md5("9ad5a1c26f7444005cc9d9cf88800a7f"),
      :project("testproject")},

     {:filename("testfile5"),
      :filesize(21),
      :md5("4f079e14c93fc0eb2b2364530ead5feb"),
      :project("testproject")}),
    'Hash list';

done-testing;
