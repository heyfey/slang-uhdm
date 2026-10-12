// § rawEndLineModel295
package pk;
  logic [7:0] \v.arr [0:1];
  struct packed { logic a; } \v.s [0:1];
endpackage
interface ifc;
  import pk::*;
  logic d;
endinterface
module dut (output logic o);
  ifc u_i ();
  assign o = 1'b0;
endmodule
