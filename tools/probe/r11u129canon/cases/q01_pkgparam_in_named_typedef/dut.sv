package pa; parameter int W = 4; endpackage
package pb; parameter int W = 4; endpackage
package p;
  typedef struct packed { logic [pa::W-1:0] m; logic n; } s_t;
endpackage
module top(input p::s_t i, output p::s_t o);
  assign o = i;
endmodule
