module m #(parameter bit P = 0)();
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
  st_t st;
  assign st.a = (P) ? 4'd5 : 4'd2;
endmodule
module top;
  m #(.P(1)) u_a();
endmodule
