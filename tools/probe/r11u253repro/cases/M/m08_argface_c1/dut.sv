// § cloneMintParentHomeCall253
package Pier;
  class keep_c; endclass
  function automatic int c1_local(input int fml_a);
    int tackle[int];
    int kink;
    kink = 1;
    tackle[kink] = 1;
    if (tackle.exists(kink)) fml_a = fml_a + 1;
    return fml_a;
  endfunction
endpackage
package Jetty;
  import Pier::*;
  function automatic int warp(input int fml_l);
    return fml_l;
  endfunction
endpackage
module top;
  import Pier::*;
  int r;
  initial r = c1_local(1) + Jetty::warp(2);
endmodule
