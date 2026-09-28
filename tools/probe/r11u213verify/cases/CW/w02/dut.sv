// § parenCastWidthRefPkgBare207 (through two packages: p2 imports and re-exports p1, a module imports p2)
package p1;
  localparam dw = 6;
  localparam m = (dw)'('h15);
endpackage
package p2;
  import p1::*;
  export p1::*;
  localparam n = dw + m;
endpackage
module top (output logic [5:0] o, output int k);
  import p2::*;
  assign o = m;
  assign k = n;
endmodule
