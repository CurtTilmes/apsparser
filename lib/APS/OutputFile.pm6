use YAML;

sub md5sum(IO::Path $f)
{
    run('md5sum', $f.absolute, :out).out.words[0];  # Get this from LVFS/DISHAS
}

class APS::OutputFile
{
    has $.file;
    has $.project;
    has $.filename;
    has $.filesize;
    has $.md5;
    has $.archiveset;
    has $.key;
    has $.datatime;
    has $.esdt;

    submethod BUILD(Str:D :$!project, IO::Path:D :$!file,
                    :$!archiveset, Str :$!key,
                    Str :$!datatime, Str :$!esdt)
    {
        $!filename = $!file.basename;
        die "Missing $!file" unless $!file.f && $!file.r;
        $!filesize = $!file.s;
        $!md5 = md5sum($!file);
    }

    method Str()
    {
        join("\n",
             "  - project: $!project",
             "    filename: $!filename",
             do for :$!filesize, :$!md5, :$!archiveset, :$!esdt, :$!key,
                    :$!datatime
             {
                 "    {.key}: {.value}" if .value.defined
             }) ~ "\n";
    }

    method hash()
    {
        %(
             :$!project, :$!filename,
             ( :$!filesize if $!filesize.defined),
             ( :$!md5 if $!md5),
             ( :$!archiveset if $!archiveset),
             ( :$!esdt if $!esdt),
             ( :$!key if $!key),
             ( :$!datatime if $!datatime)
        )
    }
}

class APS::OutputFileList
{
    has @.files;

    submethod BUILD(Str:D :$project, :$archiveset, Str:D :$dir)
    {
        my $files = do with $dir.IO.add('output').slurp
                    { yaml.load($_) } else { %() }

        my @list = $dir.IO.dir.grep: *.f;

        @!files = do for @list -> $file
        {
            next if $file.basename eq 'output';

            with $files{$file.basename}
            {
                APS::OutputFile.new(:$project, :$file, :$archiveset,
                                    esdt => .<esdt>,
                                    key => .<key> // .<datatime>,
                                    datatime => .<datatime>)
            }
            else
            {
                APS::OutputFile.new(:$project, :$file)
            }
        }
    }

    method Str() { join('', @!files».Str) }

    method hashlist() { @!files».hash }
}
