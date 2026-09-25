// § nonAnsiArrayNetAtHeader155
module dut(a, o);
  input logic [3:0] a [2];
  output logic [3:0] o;
  assign o = a[0] ^ a[1];
endmodule
