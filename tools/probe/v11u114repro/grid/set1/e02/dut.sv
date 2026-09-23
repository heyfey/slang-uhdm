// case item in an interface
package pk; parameter logic [7:0] P = {4'h7, 4'h3}; endpackage
interface ifc import pk::*; (input logic [7:0] x);
  logic [3:0] y;
  always_comb case (x) P: y = 4'd1; default: y = 4'd0; endcase
endinterface
module top(input logic [7:0] x); ifc u(.x(x)); endmodule
