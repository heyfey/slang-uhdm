// DEFPAT: an unsized '1 default imported.
package pk;
  localparam int unsigned V[2] = '{default: '1};
endpackage
module top(output int unsigned o);
  import pk::*;
  assign o = V[1];
endmodule
