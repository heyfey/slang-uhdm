// gF — R2: an UNPACKED-ARRAY package parameter whose PACKED bound reads a
// same-package parameter, plus its SCALAR sibling (the control that was
// already right before this pass).
package p;
  parameter int unsigned MSB = 33;
  parameter int N = 4;
  parameter logic [MSB:0] AddrRst[N] = '{34'h0, 34'h0, 34'h0, 34'h0};
  parameter logic [MSB:0] AddrOne = 34'h1;
endpackage
module top;
  import p::*;
  logic [MSB:0] y;
  assign y = AddrRst[0];
endmodule
