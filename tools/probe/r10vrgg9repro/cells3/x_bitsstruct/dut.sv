module m #(
  parameter bit P = 1
)();
  logic [7:0] vec;
  logic [7:0] arr[2];
  typedef struct packed { logic [3:0] a; logic [2:0] b; } st_t;

  assign arr[0] = (P) ? $bits(st_t) : 7;
endmodule
module top;
  m u_a();
endmodule
