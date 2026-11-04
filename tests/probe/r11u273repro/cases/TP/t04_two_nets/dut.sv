// § typeParamStructLastNetParent273
module dut (input logic a_i, output logic [7:0] b_o);
  localparam type it_t = struct packed { logic [7:0] x; logic [7:0] y; };
  it_t v;
  it_t w;
  always_comb v = '{x: 8'd1, y: {7'd0, a_i}};
  always_comb w = v;
  assign b_o = w.y;
endmodule
