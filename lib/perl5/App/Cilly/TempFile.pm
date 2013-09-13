package App::Cilly::TempFile;

use App::Cilly::OutputFile;
our @ISA = (App::Cilly::OutputFile);

use strict;
use Carp;
use File::Temp qw(tempfile);


########################################################################


sub new {
    croak 'bad argument count' unless @_ == 3;
    my ($proto, $basis, $suffix) = @_;
    my $class = ref($proto) || $proto;

    my ($fh, $filename) = tempfile('cil-XXXXXXXX',
				   DIR => File::Spec->tmpdir,
				   SUFFIX => ".$suffix",
				   UNLINK => 1);
    close($fh);
    if($^O eq "cygwin") {
      $filename = `cygpath -w "$filename"`;
      chomp($filename);
    }
    my $self = $class->SUPER::new($basis, $filename);
    return $self;
}


########################################################################


1;

__END__


=head1 Name

TempFile - transitory compiler output files

=head1 Synopsis

    use TempFile;

    my $cppOut = new TempFile ('code.c', 'i');
    system 'cpp', 'code.c', '-o', $cppOut->filename;

=head2 Description

C<TempFile> represents an intermediate output file generated by some
stage of a C<Cilly>-based compiler that should be removed after
compilation.  It is a concrete subclass of L<OutputFile|OutputFile>.
Use C<TempFile> when the user has asked not for intermediate files to
be retained.

All C<TempFile> files are removed when the script terminates.  This
cleanup happens for both normal exits as well as fatal errors.
However, the standard L<Perl exec function|perlfun/exec> does not
perform cleanups, and therefore should be avoided in scripts that use
C<TempFile>.

=head2 Public Methods

=over

=item new

C<new TempFile ($basis, $suffix)> constructs a new C<TempFile>
instance.  The new file name is constructed in some system-specific
temporary directory with a randomly generated file name that ends with
C<$suffix>.  For example,

    new TempFile ('/foo/code.c', 'i')

might yield a C<TempFile> with file name F</var/tmp/cil-x9GyA93R.i>.

C<$basis> gives the basis file name for this instance.  The file name
is not used directly, but is retained in case this instance is later
passed as the basis for some other C<OutputFile>.  See
L<OutputFile/"basis"> for more information on basis flattening.

C<$suffix> should not include a leading dot; this will be added
automatically.

=back

=head1 See Also

L<OutputFile>, L<TempFile>.

=cut
