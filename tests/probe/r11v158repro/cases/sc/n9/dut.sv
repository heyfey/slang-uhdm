// § sizeCastNamedWidthNoCast158v
module dut (output logic [3:0] p);
  localparam int W = 3;
  assign p = W'(-1);
endmodule
