// § nonAnsiArrayNetAtHeader155
module dut(a, o);
  input logic [3:0] a [2];
  output logic [3:0] o [2];
  assign o = a;
endmodule
module top(input logic [3:0] a [2], output logic [3:0] o [2]); dut u (a, o); endmodule
