// § pureVirtFormalSignKwTrim247
`include "h.svh"
package p1;
  virtual class base;
    `PROTO
  endclass
endpackage
package p2;
  virtual class base;
    `PROTO
  endclass
endpackage
module top;
  import p1::*;
  p1::base x;
  p2::base y;
endmodule
