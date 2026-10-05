// § cloneArrTsHomeElabFirst253
package Pier;
  class keep_c; endclass
  function automatic int f(input int fml_a);
    string acts[$];
    foreach (acts[i]) fml_a = fml_a + 1;
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
  initial r = f(1) + Jetty::warp(2);
endmodule
