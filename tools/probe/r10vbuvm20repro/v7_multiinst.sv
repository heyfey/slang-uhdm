// v7: 1..3 module instances importing the package class (instance-count axis).
package vp7;
  parameter int PW = 4096;
  typedef logic signed [PW-1:0] bs_t;
  class C7; extern function bs_t oob(); endclass
  function bs_t C7::oob(); oob = 'b0; endfunction
endpackage
module leaf7;
  import vp7::*;
  vp7::bs_t w; vp7::C7 c;
  initial begin c = new(); w = c.oob(); end
endmodule
module vt7;
  leaf7 i0(); leaf7 i1(); leaf7 i2();
endmodule
