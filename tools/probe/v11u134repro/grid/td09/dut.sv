// § defNetTypedefEndWrite134
module top(input logic c, input s_in [2], output logic o);
  typedef struct packed { logic [1:0] a; logic b; } s_t;
  s_t a [2];
  s_t k [3];
  assign a[0] = {c, c, c};
  assign k[2] = a[0];
  assign o = k[2].b ^ s_in[0];
endmodule
