// DEFPAT: an explicit import of the parameter.
package pk;
  localparam int unsigned V[2] = '{default: 3};
endpackage
module top(output int unsigned o);
  import pk::V;
  assign o = V[0];
endmodule
