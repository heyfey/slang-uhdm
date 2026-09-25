// r11u161 alias face CONTROL: module alias of a package packed struct (not an enum)
package lp;
   typedef struct packed { logic [1:0] a; logic [1:0] b; } s_t;
endpackage
module top(input logic [3:0] i, output logic [3:0] o);
  typedef lp::s_t my_s;
  my_s [0:0] w;
  assign w[0] = i;
  assign o = w[0];
endmodule
