// § sizeCastNamedWidthNoCast158v
typedef int w_t;
module dut #(parameter int N = 5) (output logic [7:0] p, output logic [7:0] q);
  localparam w_t W = 2;
  localparam int CW = $clog2(N);
  localparam int V = 13;
  assign p = W'(-1);
  assign q = CW'(V);
endmodule
