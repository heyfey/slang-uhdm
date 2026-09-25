// § nonAnsiArrayNetAtHeader155
module dut(a, o);
  input wire a [2];
  output wire o;
  assign o = a[1];
endmodule
