// § pkgExplicitImpVarReExport453
package a;
  typedef struct packed { logic [3:0] f; } s_t;
  s_t sa;
  logic [3:0] la [2];
endpackage
package b;
  import a::sa;
  import a::la;
endpackage
module top;
  import b::*;
endmodule
