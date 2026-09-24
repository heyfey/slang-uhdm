module top(input logic clk, output logic [31:0] o);
  localparam type my_t = struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; };
  my_t [2:0] arr;
  assign arr = '0;
  assign o = arr[1].a;
endmodule
