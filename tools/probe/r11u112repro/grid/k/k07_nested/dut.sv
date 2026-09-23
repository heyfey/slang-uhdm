module top(input logic clk, output logic [31:0] o);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } in_t;
  localparam type my_t = struct packed { in_t a; logic [7:0] c; };
  my_t s;
  my_t [1:0] arr;
  assign s = '0;
  assign arr = '0;
  assign o = s.c + arr[0].c;
endmodule
