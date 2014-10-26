package Vroom::Vroom::Link;

use parent qw/Vroom::Vroom/;

use strict;
use warnings;
use IO::All;

sub makeHTML {
    my $self = shift;
    require Template::Toolkit::Simple;
    $self->cleanAll;
    $self->makeSlides;
    io('html')->mkdir;
    my @slides = glob('0*');
    for (my $i = 0; $i < @slides; $i++) {
        my $slide = $slides[$i];
        my $prev = ($i > 0) ? $slides[$i - 1] : '';
        my $next = ($i + 1 < @slides) ? $slides[$i + 1] : '';
        my $text = io($slide)->all;
        my $title = $text;
		my @textwithLinks = split /(http:\/\/\S+)/, $text;
        $text = Template::Toolkit::Simple->new()->render(
            $self->slideTemplate,
            {
                title => "$slide",
                prev => $prev,
                next => $next,
                content => \@textwithLinks,
            }
        );
        io("html/$slide.html")->print($text);
    }

    my $index = [];
    for (my $i = 0; $i < @slides; $i++) {
        my $slide = $slides[$i];
        next if $slide =~ /^\d+[a-z]/;
        my $title = io($slide)->all;
        $title =~ s/.*?((?-s:\S.*)).*/$1/s;
        push @$index, [$slide, $title];
    }

    io("html/index.html")->print(
        Template::Toolkit::Simple->new()->render(
            $self->indexTemplate,
            {
                config => $self->config,
                index => $index,
            }
        )
    );
    $self->cleanUp;
}

sub slideTemplate {
    \ <<'...'
<html>
<head>
<title>[% title | html %]</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script>
function navigate(e) {
    var keynum = (window.event) // IE
        ? e.keyCode
        : e.which;
    if (keynum == 8) {
[% IF prev -%]
        window.location = "[% prev %]" + ".html";
[% END -%]
        return false;
    }
[% IF next -%]
    if (keynum == 13 || keynum == 32) {
        window.location = "[% next %]" + ".html";
        return false;
    }
[% END -%]
    if (keynum == 73 || keynum == 105) {
        window.location = "index.html";
        return false;
    }
    return true;
}
</script>
</head>
<body onkeypress="return navigate(event)">
<pre>
[%- FOREACH string IN content -%]
[%- IF string.match('(http://\S+)') -%]
<a href="[% string %]">[% string %]</a>
[%- ELSE -%]
[%- string | html -%]
[%- END -%]
[%- END -%]
</pre>
</body>
...
}


=encoding utf8

=head1 NAME

Vroom::Vroom::Link - Make Vroom::Vroom HTML links clickable

=head1 SYNOPSIS

vink --html 

=head1 DESCRIPTION

Vroom is ingy döt net's slides engine, running in vim.

For extra oomph, clickable links when publishing the slides to HTML.

=head1 SEE

L<http://search.cpan.org/perldoc?Vroom::Vroom>

=head1 AUTHOR

Dr Bean <drbean at (a) cpan dot (.) org>

=head1 COPYRIGHT

Copyright (c) 2010, Dr Bean

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut

1;
