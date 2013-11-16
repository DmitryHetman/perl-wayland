use strict;
use warnings;

use Module::Build;

# The horror below ensures that generated bindings get included in the
# distribution, as well as build when someone uses bare Git checkout.

my $build = subclass Module::Build (
code => <<'YOLO'
	sub ACTION_generate {
		my $self = shift;

		$self->depends_on ('build');

		my $protocol = $self->args ('protocol') ||
			$self->base_dir.'/protocol/wayland.xml';

		open (my $oldout, ">&STDOUT");
		close STDOUT;
		open (STDOUT, '>', $self->base_dir.'/lib/WL.pm') or die $!;
		system ($self->perl,
			'-I'.$self->blib.'/lib',
			$self->blib.'/script/wl-scanner.pl',
			$protocol);
		close STDOUT;
		open (STDOUT, '>&', $oldout);
		die 'Failed to generate protocol module' if $?;
	}

	sub ACTION_dist {
		my $self = shift;

		$self->depends_on ('generate');
		$self->SUPER::ACTION_dist (@_);
	}
YOLO
)->new(
	module_name => 'WL',
	license => 'open_source',
	dist_author => 'Lubomir Rintel <lkundrak@v3.sk>',
	dist_abstract => 'Coprosim',
	dist_version => 0.90,
	meta_merge => {
		resources => {
			bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=WL',
			repository => 'https://github.com/lkundrak/perl-wayland',
		}
	},
	configure_requires => {
		'Module::Build' => 0.40,
	},
	requires => {
		'File::Temp' => 0,
		'XML::Smart' => 0,
		'IO::Socket::UNIX' => 0,
		'Socket::MsgHdr' => 0,
	},
	build_requires => {
		'XML::Smart' => 0,
	},
	add_to_cleanup => [
		'lib/WL.pm',
	],
	get_options => {
		'protocol' => {
			type => '=s'
		},
	},
);

$build->create_build_script;
