// § decode F: f01 in a package function (no class)
package p;
  class region; endclass
  function region reserve_region(int n);
    reserve_region = null;
    if (n == 0) return reserve_region;
  endfunction
endpackage
