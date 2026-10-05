// § cloneTfFixedArrTsParented253
package Pier;
  class keep_c; endclass
  function automatic int f(input int fml_a);
    int shelf[4];
    shelf[0] = fml_a;
    return shelf[0];
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
  initial r = f(1) + Jetty::warp(2);
endmodule
