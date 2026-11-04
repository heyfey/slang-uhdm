// § tsMemberRootFile171
package p;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
endpackage
module dut import p::*; (input s_t i, output logic o);
  assign o = i.b;
endmodule
