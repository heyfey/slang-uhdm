module m(output logic [3:0] o);
  typedef struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } s_t;
  localparam s_t K = '{e: s_t'(4'b1000) >> 2, b: 2'b01};
  assign o = K;
endmodule
