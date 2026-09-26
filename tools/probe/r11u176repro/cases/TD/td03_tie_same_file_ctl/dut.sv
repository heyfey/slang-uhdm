// § tdEndMoveModuleOrder176
package pa;
  typedef struct packed { logic [1:0] x; logic y; } s_t;
endpackage
module mz import pa::*; (input logic [2:0] i, output logic o);
  s_t a [4];
  assign a[0] = i;
  assign o = a[0].y;
endmodule
module dut import pa::*; (input logic [2:0] i, output logic o, p);
  s_t b [4];
  assign b[0] = i;
  assign o = b[0].y;
  mz u1(i, p);
endmodule
