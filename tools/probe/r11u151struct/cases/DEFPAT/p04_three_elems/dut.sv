// DEFPAT: three elements.
package pk;
  localparam int unsigned V[3] = '{default: 7};
endpackage
module top(output int unsigned o);
  import pk::*;
  assign o = V[2];
endmodule
