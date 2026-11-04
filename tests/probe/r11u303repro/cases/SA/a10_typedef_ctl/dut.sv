// § sysCallArgRefScopedName303
package p;
  parameter int W = 32;
  typedef logic [W-1:0][$clog2(W)-1:0] perm_t;
endpackage
module dut (input logic i, output logic o);
  assign o = i;
endmodule
