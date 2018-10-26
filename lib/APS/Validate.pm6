use OpenAPI::Schema::Validate;

my regex project { <ident> }

my regex image-repository { 'tisaps' }

my regex image-name { <-[/:\s]>+ }

my regex image-version { \d+ '.' \d+ ( '-' \d ** 4 '-' \d ** 2 '-' \d ** 2 )? }

my regex image { <image-repository> '/' <image-name> ':' <image-version> }

my regex filename { <-[/:\s]>+ }

my regex input { || <project> '/' <filename>
                 || <filename> }

my regex swname { <ident> }

my regex swversion { <-[/:\s]>+ }

my regex software { || <project> '/' <swname> '/' <swversion>
                    || <swname> '/' <swversion>
                    || <swname> }

my regex projfilename { <project> '/' <filename> }

my regex shellstr { <-[\s]>+ }

my $schema = OpenAPI::Schema::Validate.new(
    add-formats =>
    %(
        validproject  => /^ <project> $/,
        validimage    => /^ <image> $/,
        validsoftware => /^ <software> $/,
        validvolume   => /^ <volume> $/,
        validinput    => /^ <input> $/,
        validshell    => /^ <shellstr> $/,
    ),
    schema =>
    %(
        type => 'object',
        required => (<Project Image Command>),
        properties =>
        %(
            Project => %( type => 'string', format => 'validproject' ),
            Archiveset => %( type => 'string' ),
            Image => %( type => 'string', format => 'validimage' ),
            Command => %( type => 'string', format => 'validshell' ),
            Args => %( type => 'array', items => %( type => 'string' )),
            Software =>
            %(
                type => 'array',
                items =>
                %(
                    anyOf =>
                    (
                        %( type => 'string', format => 'validsoftware' ),
                        %(
                            type => 'object',
                            required => ('name',),
                            properties =>
                            %(
                                project =>
                                %(
                                    type => 'string',
                                    format => 'validproject'
                                ),
                                name =>
                                %(
                                    type => 'string',
                                    format => 'validsoftware'
                                ),
                                version => %( type => 'string' ),
                                path => %( type => 'string' )
                            )
                        )
                    )
                )
            ),
            Input =>
            %(
                type => 'array',
                items =>
                %(
                    anyOf =>
                    (
                        %( type => 'string', format => 'validinput' ),
                        %(
                            type => 'object',
                            required => ('filename',),
                            properties =>
                            %(
                                project =>
                                %(
                                    type => 'string',
                                    format => 'validproject'
                                ),
                                filename =>
                                %(
                                    type => 'string',
                                    format => 'validinput'
                                )
                            )
                        )
                    )
                )
            )
        )
    )
);

sub validate-job($job) is export
{
    $schema.validate($job)
}
