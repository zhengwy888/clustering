package DensityCluster;
use Test::More;

require_ok("DensityClustering");
subtest "dbscan" => sub {
    $m = [[1, 1.1],
    [1.2, 0.8],
    [0.8, 1],
    [3.7, 4],
    [3.9, 3.9],
    [3.6, 4.1],
    [10,10]];
    $eps = 0.5;
    $minPoints = 2;
    is_deeply(dbscan($m, $eps, $minPoints),
    [1,1,1,2,2,2, $DensityCluster::NOISE], "clustering points as expected");
};

done_testing;
