module top(input logic clk, output logic [31:0] o);
  localparam type my_t = struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; };
  my_t [1:0][2:0] z;
  assign z = '0;
  assign o = z[1][2].a;
endmodule
