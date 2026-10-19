// § impUnbasedReadIsLit405
package p;
  localparam b_lp = '1;
endpackage
module top import p::*; #(parameter n = 2) (input logic [3:0] i, output logic [3:0] o[n]);
  for (genvar k = 0; k < n; k++) begin : g
    assign o[k] = i + b_lp;
  end
endmodule
