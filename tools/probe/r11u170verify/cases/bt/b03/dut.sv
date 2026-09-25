// § bodyTypeParamDefaultBound160
module sub (input logic clk, output logic [15:0] o);
  localparam type my_t = struct packed { logic [3:0] a; logic [3:0] b; };
  my_t [1:0] q;
  always_ff @(posedge clk) q <= '1;
  assign o = q;
endmodule
module top (input logic clk, output logic [15:0] o, output logic [15:0] o2);
  sub u1(.clk(clk), .o(o));
  sub u2(.clk(clk), .o(o2));
endmodule
