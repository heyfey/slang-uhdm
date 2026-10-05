// § cloneMintParentHomeCall253
package Pier;
  class Fender;
    int m_girth;
    function new(); m_girth = 1; endfunction
    function int rub(input int cleat);
      return cleat + m_girth;
    endfunction
  endclass
  function automatic int c7_two(input int fml_g);
    Fender fleet[$];
    Fender one;
    int    kink;
    one = new();
    fleet.push_back(one);
    kink = 0;
    return fml_g + fleet[0].rub(kink);
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
  initial r = c7_two(7) + Jetty::warp(2);
endmodule
