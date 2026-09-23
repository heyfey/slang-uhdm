module top(input logic clk, output logic [31:0] o);
  localparam type my_t = struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; };
  wire my_t s;
  wire my_t [1:0] arr;
  assign s = '0;
  assign arr = '0;
  assign o = s.a + arr[0].a;
endmodule
