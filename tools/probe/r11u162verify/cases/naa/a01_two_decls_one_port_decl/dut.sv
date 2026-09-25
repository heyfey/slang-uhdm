// § nonAnsiArrayNetAtHeader155
module dut(a, b, o);
  input logic [1:0] a [2], b [2];
  output logic [1:0] o;
  assign o = a[0] ^ b[1];
endmodule
