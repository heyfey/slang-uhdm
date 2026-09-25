// § defNetTypedefEndWrite134
module top #(parameter int K = 1);
  typedef struct packed { logic x; logic y; } s_t;
  s_t a [2];
endmodule
