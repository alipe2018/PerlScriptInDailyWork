#!/usr/bin/perl -w
use strict;
use List::Util qw/min max/;
use Data::Dumper;

## 根据表达量统计不同重复样本的差异倍数

my %hash;
open IN, $ARGV[0] || die $!;
my %name = map{chomp;my @a = split /\t/, $_;$a[0], $a[1];}<IN>;
close IN;

open ALL, $ARGV[1] || die $!;
chomp(my $head = <ALL>);
my @samples = split /\t/, $head;
my @SNPs;

while(<ALL>){
    chomp;
    my @a = split /\t/, $_;

    for (my $i=1; $i<@a; $i++){
        $hash{$samples[$i]}{$a[0]} = $a[$i];
    }
    push @SNPs, $a[0];
}
close ALL;


my %fold;
for (my $i=1; $i<@samples; $i++){
    
    for (my $j=1; $j<@samples; $j++){        
        if ($i == $j){ ##   == not =
            next;      
        }else{               
            if ($name{$samples[$i]} eq $name{$samples[$j]}){
                foreach my $g (sort @SNPs){
        
                    if ($hash{$samples[$i]}{$g} eq "0" && $hash{$samples[$j]}{$g} eq "0"){
                        print STDERR join("\t", $samples[$i], $samples[$j], $g, "0\t0\t0")."\n";
                        next;
                    }elsif($hash{$samples[$i]}{$g} eq "0" ){
                        print STDERR join("\t", $samples[$i], $samples[$j], $g, "0",$hash{$samples[$j]}{$g},"NaN")."\n";
                        next;
                    }elsif($hash{$samples[$j]}{$g} eq "0" ){
                        print STDERR join("\t", $samples[$i], $samples[$j], $g, $hash{$samples[$i]}{$g},"0\tNaN")."\n";
                        next;
                    }else{
                        my $fold = $hash{$samples[$j]}{$g} / $hash{$samples[$i]}{$g} ;
                        print STDERR join("\t", $samples[$i], $samples[$j], $g, $hash{$samples[$i]}{$g}, $hash{$samples[$j]}{$g}, $fold)."\n";
                        my $compare = "$samples[$i]-$samples[$j]";
                        push @{$fold{$compare}}, $fold;
                    }
                }
            }else{
                next;
            }
        }
    }
}


foreach my $c (sort keys %fold){
    my @arr = @{$fold{$c}};
    my $min = min(@arr);
    my $max = max(@arr);
    print join("\t", $c, $min, $max)."\n";
}

__END__
