// § defNetTypedefEndWrite134
package p;
  typedef enum logic [1:0] { R, G, B } col_t;
endpackage
module top(input logic c, output logic [1:0] o);
  import p::*;
  col_t cs [3];
  assign cs[1] = c ? G : B;
  assign o = cs[1];
endmodule
