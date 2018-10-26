use Test;
use APS::Validate;

my $project = 'testproject';

my @goodjobs =
'simple, no software' => %(
    Project => $project,
    Image => 'tisaps/foo:1.0',
    Command => '/run/this'
),
'software strings' => %(
    Project => $project,
    Image => 'tisaps/foo:1.0',
    Command => '/run/this',
    Software => ( 'pge/1.0', 'proj/pge/2.5')
    );

my @badjobs =
/:s Object does not have required property/ => %(
    Image => 'tisaps/foo:1.0',
    Command => '/run/this'
),

/:s Object does not have required property/ => %(
    Project => $project,
    Command => '/run/this'
),
/:s Object does not have required property/ => %(
    Project => $project,
    Image => 'tisaps/foo:1.0'
),
/:s Not an array/ => %(
    Project => $project,
    Image => 'tisaps/foo:1.0',
    Command => '/run/this',
    Software => 'something'
);

plan @goodjobs.elems + @badjobs.elems;

for @goodjobs -> (:key(:$comment), :value(:$job))
{
    is validate-job($job), True, $comment
}

for @badjobs -> (:key(:$message), :value(:$job))
{
    fails-like { validate-job($job) },
    X::OpenAPI::Schema::Validate::Failed, :$message;
}

done-testing;
