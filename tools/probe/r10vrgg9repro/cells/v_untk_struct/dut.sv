module m #(
  parameter bit P = 0
)();
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
  st_t st;
  logic [7:0] arr[2];
  assign arr[0] = (P) ? 42 : st.a;
endmodule
module top;
  m #(.P(1)) u_a();
endmodule
