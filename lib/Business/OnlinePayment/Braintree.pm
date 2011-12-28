package Business::OnlinePayment::Braintree;

use 5.006;
use strict;
use warnings;

use Business::OnlinePayment 3.01;
use Net::Braintree;

use base 'Business::OnlinePayment';

=head1 NAME

Business::OnlinePayment::Braintree - Online payment processing through Briantree

=head1 VERSION

Version 0.0002

=cut

our $VERSION = '0.0002';

=head1 SYNOPSIS

    use Business::OnlinePayment;

    $tx = new Business::OnlinePayment('Braintree',
                                      merchant_id => 'your merchant id',
                                      public_key => 'your public key',
                                      private_key => 'your private key',
                                     );

    $tx->test_transaction(1); # sandbox transaction for development and tests
  
    $tx->content(amount => 100,
                 card_number => '4111 1111 1111 1111',
                 expiration => '1212');

    $tx->submit();

    if ($tx->is_success) {
        print "Card processed successfully: " . $tx->authorization . "\n";
    } else {
        print "Card was rejected: " . $tx->error_message . "\n";
    }

=head1 DESCRIPTION

Online payment processing through Braintree based on L<Net::Braintree>.

=head1 NOTES

This is a very basic implementation right now and only for development purposes.
It is supposed to cover the complete Braintree Perl API finally.

=head1 METHODS

=head2 submit

Submits transaction to Braintree gateway.

=cut

sub submit {
    my $self = shift;
    my $config = Net::Braintree->configuration;
    my %content = $self->content;
    my $result;

    # sandbox vs production
    if ($self->test_transaction) {
	$config->environment('sandbox');
    }
    else {
	$config->environment('production');
    }

    # adjust format of expiration date
    $content{expiration} = substr($content{expiration}, 0, 2)
	. '/'. substr($content{expiration}, 2);

    # transaction
    $result = Net::Braintree::Transaction->sale({
	amount => $content{amount},
	credit_card => {
	    number => $content{card_number},
	    expiration_date => $content{expiration},
	}});

    if ($result->is_success()) {
	$self->is_success(1);
	$self->authorization($result->transaction->id);
    }
    else {
	$self->is_success(0);
	$self->error_message($result->message);
    }
}

=head2 set_defaults

Sets defaults for the Braintree merchant id, public and private key.

=cut
    
sub set_defaults {
    my ($self, %opts) = @_;
    my $config = Net::Braintree->configuration;

    $config->merchant_id($opts{merchant_id});
    $config->public_key($opts{public_key});
    $config->private_key($opts{private_key});

    return;
}

=head1 AUTHOR

Stefan Hornburg (Racke), C<< <racke at linuxia.de> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-business-onlinepayment-braintree at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Business-OnlinePayment-Braintree>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

You can find documentation for this module with the perldoc command.

    perldoc Business::OnlinePayment::Braintree


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Business-OnlinePayment-Braintree>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Business-OnlinePayment-Braintree>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Business-OnlinePayment-Braintree>

=item * Search CPAN

L<http://search.cpan.org/dist/Business-OnlinePayment-Braintree/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 Stefan Hornburg (Racke).

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 SEE ALSO

L<Net::Braintree>

=cut

1; # End of Business::OnlinePayment::Braintree
