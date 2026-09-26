// § tsMemberRootFile171
`define MK_T(n) typedef struct packed { logic [1:0] lo; logic hi; } n;
package p;
  `MK_T(t_t)
endpackage
module dut import p::*; (input t_t i, output logic o);
  assign o = i.hi;
endmodule
