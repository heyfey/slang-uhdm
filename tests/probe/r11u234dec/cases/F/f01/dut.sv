// § decode F (N0067 N0068, the second shape): an out-of-body method returning a class handle whose body assigns the function's own name (the return variable read as a ref_obj)
package p;
  class region; endclass
  class mam;
    extern function region reserve_region(int n);
  endclass
  function region mam::reserve_region(int n);
    reserve_region = null;
    if (n == 0) return reserve_region;
  endfunction
endpackage
