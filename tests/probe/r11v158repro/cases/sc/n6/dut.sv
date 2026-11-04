// § sizeCastNamedWidthNoCast158v
module dut (output logic signed [7:0] p);
  localparam int W = 3;
  assign p = W'(-1);
endmodule
