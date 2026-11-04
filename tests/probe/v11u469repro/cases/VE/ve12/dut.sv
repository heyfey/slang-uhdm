// § importEnumCloneHomeInst469
// an enum parameter imported by a package that a module and an interface both import
package a;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  parameter e_t PE = E1;
endpackage
package b;
  import a::*;
  localparam e_t LB = PE;
endpackage
interface ifc;
  import b::*;
  logic [1:0] s;
  assign s = LB;
endinterface
module top(output logic [1:0] y);
  import b::*;
  ifc i();
  assign y = LB;
endmodule
