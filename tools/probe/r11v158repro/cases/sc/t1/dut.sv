// § sizeCastNamedWidthNoCast158v
module dut (output logic [7:0] p, output logic [7:0] q);
  typedef logic [1:0] t2;
  assign p = t2'(7);
  assign q = t2'(-1);
endmodule
