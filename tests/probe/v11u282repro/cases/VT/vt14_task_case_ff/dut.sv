// § tfFoldCaseInsideBoundModule282
package pk; parameter logic [1:0] P_LIT = 2'd1; endpackage
module top import pk::*; (input logic clk, input logic [1:0] a, output logic z);
  task automatic t(input logic [1:0] x, output logic y);
    case (x) P_LIT: y = 1'b1; default: y = 1'b0; endcase
  endtask
  always_ff @(posedge clk) t(a, z);
endmodule
