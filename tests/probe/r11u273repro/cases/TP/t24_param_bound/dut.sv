// § typeParamStructLastNetParent273
module dut (input logic a_i, output logic [7:0] b_o);
  localparam int W = 8;
  localparam type it_t = struct packed { logic [W-1:0] x; logic [3:0] y; };
  it_t v;
  always_comb v = '{x: {7'd0, a_i}, y: 4'd2};
  assign b_o = v.x;
endmodule
