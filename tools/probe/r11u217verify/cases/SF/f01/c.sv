// § sizeDimOvrFileAtDim212 — r11u217 f01: the child in c.sv: two size dimensions from two parameters (an interface-array port and a logic-array port), both overridden from dut.sv
module c #(parameter int N = 1, parameter int M = 1) (bi.m p [N], input logic [3:0] q [M], output logic o);
  assign o = p[0].w ^ q[0][0];
endmodule
