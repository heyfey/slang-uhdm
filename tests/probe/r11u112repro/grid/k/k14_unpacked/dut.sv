module top(input logic clk, output logic [31:0] o);
  localparam type my_t = struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; };
  my_t u [2];
  assign u[0] = '0;
  assign u[1] = '0;
  assign o = u[1].a;
endmodule
