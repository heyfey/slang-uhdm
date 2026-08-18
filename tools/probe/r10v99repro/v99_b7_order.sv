// v99 b7 - ordering/reduction methods + associative arrays with a ranged inside
module mub7;
  int qa7 [$];
  int da7 [];
  int as7 [string];
  int r71 [$], r72 [$], r73 [$], r74 [$], r76 [$];
  string r75 [$];
  int s72q [$];
  int s71, s72, s73;
  initial begin
    qa7.sort(i71) with ((i71 inside {[1:5], 9}) ? i71 : 0);
    qa7.rsort(i72) with ((i72 inside {[2:6]}) ? i72 : 0);
    qa7.reverse();
    r74 = as7.find(i74) with (i74 inside {[3:7], 11});
    r75 = as7.find_index(i75) with (i75 inside {[4:8]});
    r76 = da7.unique_index(i76) with ((i76 inside {[5:9]}) ? 1 : 0);
    s71 = qa7.product(i77) with ((i77 inside {[6:10]}) ? 1 : 1);
    s72q = da7.max(i78) with (i78 inside {[7:11], 13});
    s73 = as7.sum(i79) with ((i79 inside {[8:12]}) ? 1 : 0);
  end
endmodule
