// § genLpSysCallArgName239
package p;
  parameter int W = 8;
  typedef struct packed { logic [$clog2(W)-1:0] a; logic b; } s_t;
endpackage
module top (input p::s_t r, output logic o);
  assign o = ^r;
endmodule
