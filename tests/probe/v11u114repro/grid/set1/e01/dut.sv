// case item in a module task
package pk; parameter logic [7:0] P = {4'h7, 4'h3}; endpackage
module top import pk::*; (input logic [7:0] x, output logic [3:0] y);
  task automatic t(input logic [7:0] v, output logic [3:0] o);
    case (v) P: o = 4'd1; default: o = 4'd0; endcase
  endtask
  always_comb t(x, y);
endmodule
