// case item in an elaborated generate for
package pk; parameter logic [7:0] P = {4'h7, 4'h3}; endpackage
module top import pk::*; (input logic [7:0] x, output logic [3:0] y [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    always_comb case (x) P: y[g] = 4'd1; default: y[g] = 4'd0; endcase
  end
endmodule
