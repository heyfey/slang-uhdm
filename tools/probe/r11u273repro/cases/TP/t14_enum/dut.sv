// § typeParamStructLastNetParent273
module dut (input logic a_i, output logic b_o);
  localparam type e_t = enum logic [1:0] { EA, EB, EC };
  e_t v;
  always_comb v = a_i ? EA : EB;
  assign b_o = (v == EB);
endmodule
