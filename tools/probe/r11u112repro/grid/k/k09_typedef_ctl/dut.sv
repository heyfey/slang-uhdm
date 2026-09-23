module top(input logic clk, output logic [31:0] o);
  typedef struct packed { logic [31:0] a; logic [7:0] c; } my_t;
  my_t s;
  my_t [1:0] arr;
  assign s = '0;
  assign arr = '0;
  assign o = s.a + arr[0].a;
endmodule
