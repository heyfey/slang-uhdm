// § cloneMintParentHomeCall253
package Pier;
  class keep_c; endclass
  function automatic int c8_block(input int fml_h);
    int tackle[int];
    int shelf[3];
    tackle[0] = 8;
    shelf[0] = 0;
    foreach (shelf[ix]) begin
      int nbl;
      nbl = ix;
      if (tackle.exists(ix))  fml_h = fml_h + 1;
      if (tackle.exists(nbl)) fml_h = fml_h + 1;
    end
    return fml_h;
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
  initial r = c8_block(8) + Jetty::warp(2);
endmodule
