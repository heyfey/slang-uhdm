// § anonMemberTdLastWriter212 — r11u217 s10: an anonymous struct whose member type is an IMPORTED package struct typedef, beside a MODULE PARAMETER of that typedef (its typespec a per-use copy in Surelog)
package a;
  typedef struct packed { logic x; logic [2:0] y; } e_t;
endpackage
module dut import a::*; (input logic [3:0] d, output logic o);
  parameter e_t P = '{ x: 1'b1, y: 3'd5 };
  struct packed { e_t mem; } w;
  assign w = d;
  assign o = w.mem.x ^ P.x;
endmodule
