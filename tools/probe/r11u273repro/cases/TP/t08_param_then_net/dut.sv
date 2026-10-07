// § typeParamStructLastNetParent273
module dut (input logic a_i, output logic [7:0] b_o);
  localparam type it_t = struct packed { logic [7:0] x; logic [7:0] y; };
  localparam it_t I = '{x: 8'd1, y: 8'd2};
  it_t v;
  always_comb v = a_i ? I : '0;
  assign b_o = v.x;
endmodule
