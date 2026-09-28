// § funcCfgPatDeclScope195v — v11u195 fresh: a package struct sized by a package parameter a function computes (the struct declared in the package)
package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t mk(int unsigned x); cfg_t r; r.XLEN = x; return r; endfunction
  localparam cfg_t Def = mk(8);
  typedef struct packed { logic [Def.XLEN-1:0] S; logic [Def.XLEN-1:0] M; } it_t;
endpackage
module top (input logic a, output logic [7:0] o);
  localparam cp::it_t INT = '{S: 1, M: 3};
  assign o = a ? INT.S : INT.M;
endmodule
