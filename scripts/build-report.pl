#!/usr/bin/env perl
# Build each resume variant through Make and print an Overleaf-style report:
# one status line per variant followed by a tree of LaTeX errors and warnings.
#
# Usage (normally via `make`): build-report.pl VARIANT...
# Environment: REPORT_MAKE (make command), STRICT=1 (layout warnings fail),
#              V=1 (stream raw build output), NO_COLOR (disable color).
use strict;
use warnings;
use Digest::MD5;
use File::Path qw(make_path);

my $make       = $ENV{REPORT_MAKE} || 'make';
my $strict     = ($ENV{STRICT} // '0') eq '1';
my $verbose    = ($ENV{V} // '0') eq '1';
my $max_errors = 10;

# Flush per line so the report and the stderr banner stay in order when piped.
$| = 1;

my $use_color = -t STDOUT && !defined $ENV{NO_COLOR};
my %c = map { $_ => '' } qw(green yellow red dim bold off);
%c = (green => "\e[32m", yellow => "\e[33m", red => "\e[31m",
      dim => "\e[2m", bold => "\e[1m", off => "\e[0m") if $use_color;

my @variants = @ARGV or die "usage: build-report.pl VARIANT...\n";

my %total = (built => 0, unchanged => 0, failed => 0, warned => 0);
my ($any_failed, $any_layout) = (0, 0);

for my $v (@variants) {
    my $name = "hari-resume-$v";
    my $pdf  = "build/pdf/$name.pdf";
    my $work = "build/work/$v";
    my $log  = "$work/$name.log";

    my $started = time;
    my ($status, $output_file) = build($pdf, $work, $log);
    # A log older than this run (e.g. latexmk never started) says nothing about it.
    my $log_fresh = -r $log && (stat $log)[9] >= $started;
    my $use_log   = -r $log && ($status ne 'failed' || $log_fresh);
    my $info = $use_log ? parse_log($log) : { pages => undef, errors => [], warnings => [] };

    my @items;
    if (defined $info->{pages} && $info->{pages} != 1 && $status ne 'failed') {
        my $p = $info->{pages};
        push @items, { kind => 'warn', layout => 1,
                       msg => "page count: $p page" . ($p == 1 ? '' : 's') . ' (target is 1)' };
    }
    my @errors = @{ $info->{errors} };
    for my $i (0 .. $#errors) {
        last if $i >= $max_errors;
        my $e = $errors[$i];
        push @items, { kind => 'error', msg => $e->{msg}, loc => $e->{loc}, ctx => $e->{ctx},
                       note => $i > 0 ? '(may be caused by an earlier error)' : undef };
    }
    if (@errors > $max_errors) {
        push @items, { kind => 'error', msg => '… and ' . (@errors - $max_errors) . ' more error(s); see the log' };
    }
    if ($status eq 'failed' && !@errors) {
        push @items, { kind => 'error', msg => 'build failed with no LaTeX errors in the log',
                       ctx => last_line($output_file) };
    }
    push @items, @{ $info->{warnings} };
    if ($status eq 'failed') {
        push @items, { kind => 'info', msg => 'full log: ' . (-r $log ? $log : $output_file) };
    }

    my $layout = grep { $_->{layout} } @items;
    my $warned = grep { $_->{kind} eq 'warn' } @items;
    $any_layout = 1 if $layout;
    $total{warned}++ if $warned;
    $total{ $status eq 'republished' ? 'unchanged' : $status }++;
    $any_failed = 1 if $status eq 'failed';

    print_variant($v, $status, $info->{pages}, $pdf, \@items);
}

print "\n";
my @summary = ("$total{built} built", "$total{unchanged} unchanged",
               "$total{failed} failed", "$total{warned} with warnings");
print join(' · ', @summary), "\n";
if ($total{unchanged} == @variants) {
    print "$c{dim}Nothing rebuilt: no source changes detected.$c{off}\n";
}

if ($any_layout) {
    print STDERR "\n";
    print STDERR "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
    print STDERR "!!  LAYOUT WARNING: see page-count / overfull warnings above.         !!\n";
    print STDERR "!!  Do NOT auto-fix by shrinking font size, margins, or spacing, or   !!\n";
    print STDERR "!!  by cutting content. Report it to the author and let them decide.  !!\n";
    print STDERR "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
    print STDERR "STRICT=1: failing because of layout warnings.\n" if $strict;
}

exit(($any_failed || ($strict && $any_layout)) ? 1 : 0);

# Returns (status, captured-output path). Status is one of
# built | unchanged | republished | failed.
sub build {
    my ($pdf, $work, $log) = @_;
    my $output_file = "$work/make-output.txt";
    my $published_before = digest($pdf);

    # Always run the publish rule (-B): latexmk compares file contents, which is
    # reliable where Make 3.81's 1-second timestamps are not. A no-op costs
    # well under a second and leaves an identical published PDF in place.
    my @cmd = ($make, '--no-print-directory', '-s', '-B', $pdf);
    make_path($work);
    open my $out, '>', $output_file or die "cannot write $output_file: $!\n";
    my $pid = open my $pipe, '-|';
    die "cannot fork: $!\n" unless defined $pid;
    if (!$pid) {
        open STDERR, '>&', \*STDOUT or die "cannot redirect stderr: $!\n";
        exec @cmd or die "cannot run $cmd[0]: $!\n";
    }
    my $nothing_to_do = 0;
    while (my $line = <$pipe>) {
        print {$out} $line;
        print $line if $verbose;
        $nothing_to_do = 1 if $line =~ /^Latexmk: Nothing to do for /;
    }
    close $pipe;
    my $exit = $?;
    close $out;
    return ('failed', $output_file) if $exit != 0;
    return ('built', $output_file) unless $nothing_to_do;
    # No compile, but the published copy was missing or stale (e.g. after a
    # failed publish): it now matches the last successful compile.
    my $published_after = digest($pdf) // '';
    return ('republished', $output_file) if ($published_before // '') ne $published_after;
    return ('unchanged', $output_file);
}

sub digest {
    my ($file) = @_;
    open my $fh, '<:raw', $file or return undef;
    my $md5 = Digest::MD5->new->addfile($fh)->hexdigest;
    close $fh;
    return $md5;
}

sub parse_log {
    my ($log) = @_;
    open my $fh, '<', $log or return { pages => undef, errors => [], warnings => [] };
    my @lines = <$fh>;
    close $fh;
    s/\r?\n\z// for @lines;

    my ($pages, @errors, @warnings, %seen_warning, %seen_error);
    for (my $i = 0; $i < @lines; $i++) {
        my $line = $lines[$i];

        if ($line =~ /^Output written on .*\((\d+) pages?,/) { $pages = $1; next }
        if ($line =~ /^No pages of output\./)               { $pages = 0;  next }

        # Errors in -file-line-error form: ./file.tex:42: message
        if ($line =~ m{^(?:\./)?([^:\s][^:]*\.(?:tex|sty|cls|cfg|def|clo|fd)):(\d+): (.*)$}) {
            my ($file, $ln, $msg) = ($1, $2, $3);
            my $ctx;
            for my $j ($i + 1 .. ($i + 12 < $#lines ? $i + 12 : $#lines)) {
                if ($lines[$j] =~ /^(l\.\d+ .*)$/) { $ctx = $1; last }
            }
            my $key = "$file:$ln:$msg";
            push @errors, { msg => $msg, loc => "$file:$ln", ctx => $ctx } unless $seen_error{$key}++;
            next;
        }
        # Errors without a file position (fatal errors, job aborted).
        if ($line =~ /^! (.*)$/) {
            my $msg = $1;
            $msg =~ s/^\s*==>\s*//;
            push @errors, { msg => $msg } unless $seen_error{$msg}++;
            next;
        }

        my ($source, $msg, $layout);
        if ($line =~ /^(?:LaTeX(?: (\S+))?|Package (\S+)|Class (\S+)|Module (\S+)) Warning: (.*)$/) {
            $source = $2 // $3 // $4;     # package/class name; plain LaTeX warnings get no prefix
            $msg = $5;
            my $cont = $1 // $2 // $3 // $4 // 'LaTeX';
            while ($i + 1 < @lines && $lines[$i + 1] =~ /^\(\Q$cont\E\)\s+(.*)$/) {
                $msg .= " $1";
                $i++;
            }
        }
        elsif ($line =~ /^((?:Over|Under)full \\[hv]box \([^)]*\))\s*(.*)$/) {
            $msg = $1;
            my $rest = $2;
            $layout = $msg =~ /^Overfull/ ? 1 : 0;
            if    ($rest =~ /at lines? (\d+)--(\d+)/) { $msg .= " at lines $1–$2" }
            elsif ($rest =~ /at line (\d+)/)          { $msg .= " at line $1" }
            elsif ($rest ne '')                       { $msg .= " $rest" }
        }
        elsif ($line =~ /^(Missing character: .*)$/ || $line =~ /^(pdfTeX warning.*)$/) {
            $msg = $1;
        }
        next unless defined $msg;

        my $loc;
        if ($msg =~ s/\s*on input line (\d+)\.?\s*$//) { $loc = "input line $1" }
        $msg =~ s/\s+/ /g;
        $msg = "$source: $msg" if defined $source;

        my $key = join "\0", $msg, $loc // '';
        if (my $existing = $seen_warning{$key}) { $existing->{count}++; next }
        my $w = { kind => 'warn', msg => $msg, loc => $loc, count => 1, layout => $layout };
        $seen_warning{$key} = $w;
        push @warnings, $w;
    }
    return { pages => $pages, errors => \@errors, warnings => \@warnings };
}

sub print_variant {
    my ($v, $status, $pages, $pdf, $items) = @_;
    my $page_text = defined $pages ? sprintf('%-8s', $pages . ' page' . ($pages == 1 ? '' : 's')) : '';

    my $head;
    if ($status eq 'built') {
        $head = "$c{green}✔ built    $c{off}  $page_text  $pdf";
    }
    elsif ($status eq 'unchanged') {
        $head = "$c{dim}· unchanged$c{off}  $page_text  $pdf";
    }
    elsif ($status eq 'republished') {
        $head = "$c{dim}· unchanged$c{off}  $page_text  $pdf $c{dim}(republished from the last successful compile)$c{off}";
    }
    else {
        my $kept = -e $pdf ? 'previous PDF kept, not updated' : 'no PDF published';
        $head = "$c{red}$c{bold}✘ FAILED   $c{off}  $kept";
    }
    printf "%-9s %s\n", $v, $head;

    for my $i (0 .. $#$items) {
        my $item = $items->[$i];
        my $last = $i == $#$items;
        my $branch = $last ? '└─' : '├─';
        my $pipe   = $last ? '   ' : '│  ';

        my $symbol = $item->{kind} eq 'error' ? "$c{red}✘$c{off}"
                   : $item->{kind} eq 'warn'  ? "$c{yellow}⚠$c{off}"
                   :                            "$c{dim}→$c{off}";
        my $text = $item->{msg};
        $text .= "   $c{dim}$item->{loc}$c{off}" if defined $item->{loc};
        $text .= "   ×$item->{count}" if ($item->{count} // 1) > 1;
        $text .= "   $c{dim}$item->{note}$c{off}" if defined $item->{note};
        print "  $branch $symbol $text\n";
        print "  $pipe     $c{dim}$item->{ctx}$c{off}\n" if defined $item->{ctx};
    }
}

sub last_line {
    my ($file) = @_;
    open my $fh, '<', $file or return undef;
    my $last;
    # Skip Make's own "*** [...] Error N" lines; the tool's message is more useful.
    while (my $line = <$fh>) { $last = $line if $line =~ /\S/ && $line !~ /^make(?:\[\d+\])?: / }
    close $fh;
    return undef unless defined $last;
    $last =~ s/\s+\z//;
    return $last;
}
