// § enumTdLastWriter214 § anonMemberTdUseCopyKeeps217v — the enum alias read by a $unit class (the class writer) and by a module localparam's own typespec copy and an anonymous union member in an interface
package p;
  typedef enum logic [1:0] {B0, B1} b_t;
  typedef b_t ALIAS_T;
endpackage
import p::*;
class cw_c;
  ALIAS_T a;
endclass
interface ifc;
  union packed { p::b_t u; logic [1:0] r; } un;
endinterface
module top(output logic [1:0] o);
  localparam ALIAS_T LP = B1;
  ifc i();
  assign o = LP;
endmodule
