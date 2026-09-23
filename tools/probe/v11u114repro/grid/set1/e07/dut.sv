// module-local localparam shadows nothing; a local copy with the same value, plus the imported read
package pk; parameter logic [7:0] P = {4'h7, 4'h3}; parameter logic [7:0] R = {4'h1, 4'h1}; endpackage
module top import pk::*; (input logic [7:0] x, output logic [3:0] y);
  localparam logic [7:0] P = 8'h99;
  always_comb case (x) P: y = 4'd1; R: y = 4'd2; default: y = 4'd0; endcase
endmodule
