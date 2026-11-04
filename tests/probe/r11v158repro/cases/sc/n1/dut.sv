// § sizeCastNamedWidthNoCast158v
module dut (output logic [7:0] p);
  localparam int W = 2;
  localparam int V = 7;
  assign p = W'(V);
endmodule
