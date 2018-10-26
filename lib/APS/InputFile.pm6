class APS::InputFile
{
    has $.project;
    has $.filename;

    multi submethod BUILD(Str:D :$project, Str:D :$item)
    {
        self.BUILD: :$project, item => %( filename => $item )
    }

    multi submethod BUILD(:%item, Str:D :$project)
    {
        given %item
        {
            my @parts = .<filename>.comb(/<-[/]>+/);
            if @parts.elems == 2
            {
                die "File can't have project in field and filename: $_"
                    if .<project>.defined;
                $!project = @parts[0];
                $!filename = @parts[1];
            }
            elsif @parts.elems == 1
            {
                $!project = .<project> // $project;
                $!filename = .<filename>;
            }
            else
            {
                die "Bad file: $_"
            }
        }
    }

    method Str()
    {
        "  - project: $!project\n" ~
        "    filename: $!filename\n"
    }

    method volume() { "$*APSROOT/$!project/data/$!filename" }

    method hash() { %( :$!project, :$!filename ) }
}

class APS::InputFileList
{
    has @.files;

    multi submethod BUILD(Str:D :$project, :@list)
    {
        @!files = do for @list -> $item { APS::InputFile.new(:$project, :$item) }
    }

    method volumes()
    {
        @!files.map({ '-v', "{.volume}:/home/aps/input/{.filename}:ro" }).flat
    }

    method Str() { join('', @!files».Str) }

    method hashlist() { @!files».hash }
}
