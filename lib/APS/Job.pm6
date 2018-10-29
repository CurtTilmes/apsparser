use LibUUID;
use YAML;
use APS::Software;
use APS::InputFile;
use APS::OutputFile;
use APS::Validate;

class APS::Job
{
    has $.runid;
    has $.yaml;
    has $.project;
    has $.archiveset;
    has $.image;
    has $.command;
    has @.args;
    has $.software;
    has $.inputs;
    has $.outputs;
    has $.statistics = %();

    submethod BUILD(:$!yaml,
                    :$command,
                    :$!runid = UUID.new.Str,
                    :%job (:Project(:$!project),
                           :Image(:$!image),
                           :Archiveset(:$!archiveset),
                           :Command(:$!command),
                           :Args(:@!args),
                           :Software(:@software),
                           :Input(:@input), *%))
    {
        $!software = APS::SoftwareList.new(:$!project, list => @software);
        $!inputs = APS::InputFileList.new(:$!project, list => @input);
        $!command //= '';
        $!command = $command if $command;
    }

    method read-output(Str:D $dir = '.')
    {
        $!outputs = APS::OutputFileList.new(:$!project, :$!archiveset, :$dir)
    }

    method Str()
    {
        qq:to/END/
        Project: $!project

        Archiveset: {$!archiveset // ''}

        Image: $!image

        Command: $!command

        Args: [ @!args[].map({ qq{"$_"} }).join(',') ]

        Software:
        $!software
        Input:
        $!inputs
        END
        ~
        ($!outputs ?? qq:to/END/ !! '')
        Output:
        $!outputs
        Statistics:
        $!statistics
        END
    }
}

sub parsejobs(Str:D $jobfile, Str :$command, Str :$project) is export
{
    do for open($jobfile, nl-in => "---\n").lines(:close) -> $yaml
    {
        my $job = yaml.load($yaml) or die "Can't parse $jobfile";

        $job<Project> //= $project;

        validate-job($job);

        APS::Job.new(:$yaml, :$job, :$command)
    }
}

sub read-input-job(Str:D $runid) is export
{
    my $job = yaml.load("$*APSDIR/$runid.input".IO.slurp)
        or die "Can't parse $runid.input";

    APS::Job.new(:$job, :$runid)
}
