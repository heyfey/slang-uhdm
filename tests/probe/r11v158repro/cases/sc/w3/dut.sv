// § sizeCastNamedWidthNoCast158v
module dut (output logic [7:0] p);
  localparam int W = 2;
  assign p = W'(7);
endmodule
