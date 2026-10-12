// § elabImpSelFlatKeepsParent302
// vg04: an interface imports the package whose pattern is selected; a module reads the interface
package p7;
  typedef struct packed { logic [31:0] a; logic [31:0] b; } w7_t;
  localparam w7_t WSEL = '{a: 32'd4, b: 32'd5};
  typedef logic [WSEL.a-1:0] w1_t;
endpackage
interface ifc;
  import p7::*;
  w1_t d;
endinterface
module dut(output logic [3:0] o);
  ifc i0 ();
  assign i0.d = '0;
  assign o = i0.d;
endmodule
