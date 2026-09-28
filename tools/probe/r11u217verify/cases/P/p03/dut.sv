// § pkgImpParamMemberColons210 — r11u217 p03: explicit single-name imports into the importing package (`import a::EA;`), a nested struct parameter, and the module importing BOTH packages directly and reading a's parameter through b's copy
package a;
  typedef struct packed { logic [1:0] u; } in_t;
  typedef struct packed { in_t n; logic v; } e_t;
  parameter e_t EA = '{ n: '{ u: 2'd1 }, v: 1'b0 };
  parameter e_t EB = '{ n: '{ u: 2'd2 }, v: 1'b1 };
endpackage
package b;
  import a::EA;
  import a::e_t;
  parameter e_t LB = EA;
endpackage
module dut import a::*; import b::*; (output logic [2:0] o, output logic [2:0] p);
  assign o = LB;
  assign p = EB;
endmodule
