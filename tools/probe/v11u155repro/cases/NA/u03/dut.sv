// § nonAnsiArrayNetAtHeader155
module dut(a, o);
  input logic a [2][3];
  output logic o;
  assign o = a[0][1];
endmodule
