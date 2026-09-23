// casez item + multi-instance with a module parameter
package pk; parameter logic [7:0] P = {4'b1?0?, 4'h3}; endpackage
module sub import pk::*; #(parameter int W = 1) (input logic [7:0] x, output logic [3:0] y);
  always_comb casez (x) P: y = W[3:0]; default: y = 4'd0; endcase
endmodule
module top(input logic [7:0] x, output logic [3:0] y1, y2);
  sub #(.W(1)) a(.x(x), .y(y1));
  sub #(.W(2)) b(.x(x), .y(y2));
endmodule
