// § sizeCastNamedWidthNoCast158v
module dut #(parameter int W = 3) (output logic [7:0] p);
  assign p = W'(-1);
endmodule
