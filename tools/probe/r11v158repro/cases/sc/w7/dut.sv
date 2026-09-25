// § sizeCastNamedWidthNoCast158v
module dut #(parameter int N = 4) (output logic [7:0] p);
  localparam int W = $clog2(N);
  assign p = W'(7);
endmodule
