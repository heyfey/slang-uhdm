// face-2 unqualified: concat param read in case item AND if-cond AND rhs of same always
package pk; parameter logic [7:0] P = {4'h7, 4'h3}; parameter logic [7:0] N = ~8'h0F; endpackage
module top import pk::*; (input logic [7:0] x, output logic [3:0] y, output logic [7:0] z);
  always_comb begin
    z = P;
    if (x == P) y = 4'd3;
    else case (x) P: y = 4'd1; N: y = 4'd2; default: y = 4'd0; endcase
  end
endmodule
