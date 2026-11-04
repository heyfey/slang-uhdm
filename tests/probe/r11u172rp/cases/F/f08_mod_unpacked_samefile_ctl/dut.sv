package pa;
  typedef struct packed { logic [1:0] x; logic y; } s_t;
endpackage
module top import pa::*; (input logic [2:0] i, output logic o);
  s_t a [4];
  assign a[0] = i;
  assign o = a[0].y;
endmodule
