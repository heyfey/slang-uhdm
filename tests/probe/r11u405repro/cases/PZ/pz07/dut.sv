// § impUnbasedReadIsLit405
module top (input logic [3:0] i, output logic [3:0] o);
  localparam a_lp = '0;
  assign o = i + a_lp;
endmodule
