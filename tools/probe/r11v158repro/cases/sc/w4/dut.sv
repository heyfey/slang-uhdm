// § sizeCastNamedWidthNoCast158v
module dut #(parameter int W = 2) (output logic [7:0] p);
  assign p = W'(7);
endmodule
