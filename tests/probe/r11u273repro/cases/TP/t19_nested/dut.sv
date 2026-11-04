// § typeParamStructLastNetParent273
module dut (input logic a_i, output logic [7:0] b_o);
  localparam type it_t = struct packed { struct packed { logic [7:0] p; logic q; } s; logic [7:0] y; };
  it_t v;
  always_comb v = '0;
  assign b_o = v.s.p;
endmodule
