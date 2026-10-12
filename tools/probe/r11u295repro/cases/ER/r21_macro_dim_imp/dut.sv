// § rawEndLineModel295
`define N 2
package pk;
  logic [7:0] varr [0:`N-1];
endpackage
module dut (output logic [7:0] o);
  import pk::*;
  logic [7:0] narr [0:`N-1];
  assign narr[0] = 8'h1;
  assign o = varr[0] ^ narr[0];
endmodule
