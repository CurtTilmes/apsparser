#
# For each volume that gets mounted, each /<path>/<dir>
# gets added to the environment variable.  Each element separated by 'sep'
#
my @envmap =
    %( var => 'PATH',
       dir => 'bin',
       sep => ':',
       def => '/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' ),
    %( var => 'PERL5LIB',
       dir => 'lib/perl',
       sep => ':',
       def => '/usr/local/lib/perl' );

class APS::Software
{
    has $.project;
    has $.name;
    has $.version;
    has $.path;

    multi submethod BUILD(Str:D :$item, Str:D :$project)
    {
        self.BUILD: :$project, item => %( name => $item)
    }

    multi submethod BUILD(:%item, Str:D :$project)
    {
        given %item
        {
            $!project = .<project> // $project;
            die "Must specify Software name" unless .<name>;
            my @parts = .<name>.comb(/<-[/]>+/);
            if @parts.elems == 3
            {
                die "Software can't have project in name and project $_"
                    if .<project>:exists;
                die "Software can't have version in name and version $_"
                    if .<version>:exists;
                $!project = @parts[0];
                $!name    = @parts[1];
                $!version = @parts[2];
            }
            elsif @parts.elems == 2
            {
                die "Software can't have version in name and version, $_"
                    if .<version>:exists;
                $!project = .<project> // $project;
                $!name    = @parts[0];
                $!version = @parts[1];
            }
            elsif @parts.elems == 1
            {
                $!name = .<name>;
                $!version = .<version> // die "Must specify version, $_";
            }
            else
            {
                die "Bad software $_";
            }
            $!path = .<path> // "/opt/$!name";
        }
    }

    method volume() { "$*APSRELEASE/$!project/$!name/$!version" }

    method Str()
    {
        qq:to/END/
          - project: $!project
            name: $!name
            version: $!version
            path: $!path
        END
    }

    method hash() { %( :$!project, :$!name, :$!version ) }
}

class APS::SoftwareList
{
    has @.software;

    submethod BUILD(Str:D :$project, :@list)
    {
        my %seen;
        for @list
        {
            my $sw = APS::Software.new(:$project, item => $_);
            die "Multiple definitions for $sw.path()" if %seen{$sw.path}++;
            @!software.push: $sw
        }
    }

    method volumes() { @!software.map({ '-v', "{.volume}:{.path}:ro" }).flat }

    method Str() { (@!software».Str).join('') }

    method hashlist() { @!software».hash }

    method env()
    {
        do for @envmap -> % (:$var, :$dir, :$sep, :$def)
        {
            slip '-e',
            "$var=" ~ join($sep, @!software.map(
                { .volume.IO.add($dir).d ?? "{.path}/$dir" !! () }), $def)
        }
    }
}
