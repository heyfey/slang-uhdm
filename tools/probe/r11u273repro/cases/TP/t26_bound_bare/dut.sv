// § typeParamStructLastNetParent273
module dut #(parameter int N = 4) (input logic a_i, output logic [7:0] b_o);
  localparam type it_t = struct packed { logic [N:0] x; logic [N*2-1:0] y; };
  it_t v;
  always_comb v = '0;
  assign b_o = 8'(v.y);
endmodule
