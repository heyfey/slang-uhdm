// r11u57 — THE OTHER DesignComponent KINDS for the buried call: an
// elaborated PACKAGE parameter and an INTERFACE body localparam.  r11u53's
// w4/w6 proved the component kind is not a gate for the whole-Rhs shape;
// this asks the same of the buried one, in the view this pass writes.
package pk;
  typedef struct packed { logic [2:0] a; } req_t;                   // 3
endpackage
package pp;
  parameter  type PT = pk::req_t;
  parameter  int  PW = (1 << $bits(PT));          // package, buried
  parameter  int  PD = (1 << $bits(pk::req_t));   // CONTROL
endpackage
interface ifc #(parameter type IT = logic [1:0]) ();
  localparam int IW = (1 << $bits(IT));           // interface body, buried
  localparam int ID = (1 << $bits(pk::req_t));    // CONTROL
endinterface
module dut (output logic o);
  ifc i0 ();
  assign o = ^{pp::PW[0], pp::PD[0]};
endmodule
