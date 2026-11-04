// § typeParamStructLastNetParent273
module top(input logic clk, output logic [31:0] o);
  localparam type my_t = struct packed { logic [31:0] a; logic [15:0] b; };
  my_t u [2];
  always_comb begin u[0] = '0; u[1] = '1; end
  assign o = u[1].a;
endmodule
