=pod
Density clustering bundle for perl
=cut
package DensityCluster;
use strict;
use warnings;

our $UNCLASSIFIED = -1;
our $NOISE = 0;
# modeled after the python implementation on github
# $m is a two dimension array
sub dbscan {
    my ($m, $eps, $minPoints) = @_;
    my $clusterId = 1;
    my $nPoints = scalar(@$m);
    my $classification = [map { $UNCLASSIFIED } (0..($nPoints-1))];
    foreach my $pointId (0..($nPoints-1)) {
        if ($classification->[$pointId] == $UNCLASSIFIED) {
           if ( _expand_cluster($m, $classification, $pointId, $clusterId, $eps, $minPoints) ) {
               $clusterId += 1;
           }
        }
    }
    return $classification;
}

sub _expand_cluster {
    my ($m, $classification, $pointId, $clusterId, $eps, $minPoints) = @_;
    my $seeds = _region_query($m, $pointId, $eps);
    if ( scalar(@$seeds) < $minPoints ) {
        $classification->[$pointId] = $NOISE;
        return 0;
    } else {
        $classification->[$pointId] = $clusterId;
        foreach my $seed (@$seeds) {
            $classification->[$seed] = $clusterId;
        }
        while ( scalar(@$seeds) > 0) {
            my $currentPoint = shift(@$seeds);
            my $results = _region_query($m, $currentPoint, $eps);
            if ( scalar(@$results) >= $minPoints ) {
                foreach my $i (0..(scalar(@$results)-1)) {
                    my $resultp = $results->[$i];
                    my $c = $classification->[$resultp];
                    if ($c == $UNCLASSIFIED || $c == $NOISE) {
                        if ( $c == $UNCLASSIFIED ) {
                            push(@$seeds, $resultp);
                        }
                        $classification->[$resultp] = $clusterId;
                    }
                }
            }
        }
        return 1;
    }
}

sub pluck_column {
    my ($m, $col) = @_;
    return [map { $_->[$col] } @$m];
}

sub _region_query {
    my ($m, $pointId, $eps) = @_;
    my $nPoints = scalar(@$m);
    my $seeds = [];
    foreach my $i (0..($nPoints-1)) {
        if (_eps_neighbor($m->[$pointId], $m->[$i], $eps) ) {
            push(@$seeds, $i)
        }
    }
    return $seeds;
}

sub _eps_neighbor {
    my ($p, $q, $eps) = @_;
    return distance($p, $q) < $eps;
}

#
sub distance {
    my ($p, $q) = @_;
    my $colCount = scalar(@$p);
    my $dist2 = 0;
    foreach my $i (0..($colCount-1)) {
        $dist2 += ($p->[$i] - $q->[$i])**2;
    }
    return sqrt($dist2);
}
1;
