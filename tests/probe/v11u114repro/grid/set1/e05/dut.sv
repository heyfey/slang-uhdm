// case inside with the param as an item
package pk; parameter logic [7:0] P = {4'h7, 4'h3}; endpackage
module top import pk::*; (input logic [7:0] x, output logic [3:0] y);
  always_comb case (x) inside P: y = 4'd1; [8'h10:8'h20]: y = 4'd2; default: y = 4'd0; endcase
endmodule
