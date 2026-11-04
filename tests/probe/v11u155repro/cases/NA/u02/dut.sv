// § nonAnsiArrayNetAtHeader155
module dut(a, b);
  input [3:0] a [0:1];
  output [3:0] b [0:1];
  assign b = a;
endmodule
