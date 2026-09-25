// § sizeCastNamedWidthNoCast158v
module dut (output logic [7:0] p, output logic [7:0] q);
  localparam int W = 2;
  localparam int V = 7;
  assign p = W'(V + 1);
  assign q = W'(3 + 4);
endmodule
