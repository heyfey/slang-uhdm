// § ppOutputFile166 § ppOutputLine166
`define XW \
  64
module top(input logic [7:0] a, output logic [7:0] y, output logic [7:0] z, output logic [7:0] w);
  function automatic int f(int x, int y); return x + y; endfunction
  localparam int K = f(`XW,
    5);
  assign y = a + K;
  assign z = a;
  assign w = a;
endmodule
