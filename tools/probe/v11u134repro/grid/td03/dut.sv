// § defNetTypedefEndWrite134
module top(input logic c, output logic [1:0] o);
  typedef enum logic [1:0] { R, G, B } col_t;
  col_t a [2], b [3][2];
  assign a[0] = c ? R : G;
  assign b[1][0] = B;
  assign o = a[0] ^ b[1][0];
endmodule
