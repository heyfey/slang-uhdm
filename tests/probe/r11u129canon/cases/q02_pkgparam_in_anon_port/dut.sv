package pa; parameter int W = 4; endpackage
package pb; parameter int W = 4; endpackage
module top(input logic [pa::W-1:0] i, output logic [3:0] o);
  assign o = i;
endmodule
