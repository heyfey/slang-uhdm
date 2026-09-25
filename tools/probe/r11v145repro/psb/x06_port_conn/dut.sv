// § psBoundBareRefByBase145
module c(input logic [4:0] x, output logic [4:0] y);
  assign y = x;
endmodule
module dut(input logic [31:0] a, output logic [4:0] o);
  localparam int W = 8;
  localparam int L = 4;
  c u(.x(a[W:L]), .y(o));
endmodule
