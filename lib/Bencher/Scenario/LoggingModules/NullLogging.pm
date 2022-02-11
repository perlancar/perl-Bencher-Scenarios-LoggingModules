package Bencher::Scenario::LoggingModules::NullLogging;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

#use Bencher::ScenarioUtil::LoggingModules::Participant;

our $scenario = {
    summary => 'Benchmark logging statement that does not output anywhere '.
        '(to measure logging overhead)',
    modules => {
        'Log::Any' => {},
        'Log::Contextual' => {},
        'Log::Dispatchouli' => {},
        'Log::Dispatch::Null' => {},
        'Log::Fast' => {},
        'Log::ger' => {},
        'Log::ger::Plugin::OptAway' => {},
        'Log::Log4perl' => {},
        'Log::Log4perl::Tiny' => {},
        'Log::Mini' => {},
        'Mojo::Log' => {},
        'XLog' => {},
    },
    participants => [

        {
            name => 'Log::Any-no_adapter-100k_log_trace',
            perl_cmdline_template => ['-MLog::Any', '-e', 'my $log = Log::Any->get_logger; for(1..100_000) { $log->trace(q[]) }'],
        },
        {
            name => 'Log::Any-null_adapter-100k_log_trace',
            perl_cmdline_template => ['-MLog::Any', '-MLog::Any::Adapter', '-e', 'Log::Any::Adapter->set(q[Null]); my $log = Log::Any->get_logger; for(1..100_000) { $log->trace(q[]) }'],
        },

        {
            name => 'Log::Contextual+Log4perl-100k_trace' ,
            perl_cmdline_template => ['-e', 'use Log::Contextual ":log", "set_logger"; use Log::Log4perl ":easy"; Log::Log4perl->easy_init($DEBUG); my $logger = Log::Log4perl->get_logger; set_logger $logger; for(1..100_000) { log_trace {} }'],
        },
        {
            name => 'Log::Contextual+SimpleLogger-100k_trace' ,
            perl_cmdline_template => ['-MLog::Contextual::SimpleLogger', '-e', 'use Log::Contextual ":log", -logger=>Log::Contextual::SimpleLogger->new({levels=>["debug"]}); for(1..100_000) { log_trace {} }'],
        },

        {
            name => 'Log::Dispatch::Null-100k_debug' ,
            perl_cmdline_template => ['-MLog::Dispatch', '-e', 'my $null = Log::Dispatch->new(outputs=>[["Null", min_level=>"debug"]]); for(1..100_000) { $null->debug("") }'],
        },

        {
            name => 'Log::Dispatchouli-100k_debug' ,
            perl_cmdline_template => ['-MLog::Dispatchouli', '-e', '$logger = Log::Dispatchouli->new({ident=>"ident", facility=>"facility", to_stdout=>1, debug=>0}); for(1..100_000) { $logger->log_debug("") }'],
        },

        {
            name => 'Log::Fast-100k_DEBUG',
            perl_cmdline_template => ['-MLog::Fast', '-e', '$LOG = Log::Fast->global; $LOG->level("INFO"); for(1..100_000) { $LOG->DEBUG(q()) }'],
        },

        {
            name => 'Log::ger-100k_log_trace',
            perl_cmdline_template => ['-MLog::ger', '-e', 'for(1..100_000) { log_trace(q[]) }'],
        },
        {
            name => 'Log::ger+LGP:OptAway-100k_log_trace',
            perl_cmdline_template => ['-MLog::ger::Plugin=OptAway', '-MLog::ger', '-e', 'for(1..100_000) { log_trace(q[]) }'],
        },
        {
            name => 'Log::ger-1mil_log_trace',
            perl_cmdline_template => ['-MLog::ger', '-e', 'for(1..1_000_000) { log_trace(q[]) }'],
            include_by_default => 0,
        },
        {
            name => 'Log::ger+LGP:OptAway-1mil_log_trace',
            perl_cmdline_template => ['-MLog::ger::Plugin=OptAway', '-MLog::ger', '-e', 'for(1..1_000_000) { log_trace(q[]) }'],
            include_by_default => 0,
        },

        {
            name => 'Log::Log4perl-easy-100k_trace' ,
            perl_cmdline_template => ['-MLog::Log4perl=:easy', '-e', 'Log::Log4perl->easy_init($ERROR); for(1..100_000) { TRACE "" }'],
        },

        {
            name => 'Log::Log4perl::Tiny-100k_trace' ,
            perl_cmdline_template => ['-MLog::Log4perl::Tiny=:easy', '-e', 'for(1..100_000) { TRACE "" }'],
        },

        {
            name => 'Log::Mini-100k_trace',
            perl_cmdline_template => ['-MLog::Mini', '-e', '$log = Log::Mini->new("stderr"); for(1..100_000) { $log->trace(q[]) }'],
        },
        {
            name => 'Mojo::Log-100k_debug' ,
            perl_cmdline_template => ['-MMojo::Log', '-e', '$log = Mojo::Log->new(level=>"warn"); for(1..100_000) { $log->debug("") }'],
        },

        {
            name => 'XLog-100k_debug' ,
            perl_cmdline_template => ['-MXLog', '-e', 'for(1..100_000) { XLog::debug("") }'],
        },
    ],
    precision => 6,
};

1;
# ABSTRACT:

=head1 BENCHMARK NOTES

You might notice that L<Log::ger>+L<Log::ger::Plugin::OptAway> (LGP:OptAway) is
slower than plain Log::ger at 100k trace. This is because the plugin loading and
setup overhead eclipses the gain provided by the OptAway plugin. If you try the
these not-included-by-default participants they will show the benefit of
OptAway:

 Log::ger-1mil_log_trace
 Log::ger+LGP:OptAway-1mil_log_trace
