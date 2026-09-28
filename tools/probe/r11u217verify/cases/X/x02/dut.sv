// § anonMemberTdLastWriter212 § pkgImpParamMemberColons210 — r11u217 x02: an anonymous struct whose member type is a package struct typedef that an IMPORTING package re-lists with a struct parameter, the module importing both
package a;
  typedef struct packed { logic x; logic [2:0] y; } e_t;
  parameter e_t EA = '{ x: 1'b1, y: 3'd2 };
endpackage
package b;
  import a::*;
  parameter logic LB = 1'b1;
endpackage
module dut import a::*; import b::*; (input logic [3:0] d, output logic o);
  struct packed { e_t mem; } w;
  assign w = d;
  assign o = w.mem.x ^ LB ^ EA.x;
endmodule
