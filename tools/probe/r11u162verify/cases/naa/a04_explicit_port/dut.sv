// § nonAnsiArrayNetAtHeader155
module dut(.a(x), o);
  input logic [1:0] x [2];
  output logic [1:0] o;
  assign o = x[0] | x[1];
endmodule
