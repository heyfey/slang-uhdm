// § funcCfgPatDeclScope195v — v11u195 fresh: a package struct sized by the package's own constant X, the module declaring its own X from the function-valued parameter (the dimension's name resolves in the package)
package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t mk(int unsigned x); cfg_t r; r.XLEN = x; return r; endfunction
  localparam int X = 8;
  typedef struct packed { logic [X-1:0] S; logic [X-1:0] M; } it_t;
endpackage
module top #(parameter cp::cfg_t Cfg = cp::mk(8)) (input logic a, output logic [7:0] o);
  localparam int X = Cfg.XLEN;
  localparam cp::it_t INT = '{S: 1, M: 3};
  assign o = a ? INT.S : INT.M;
endmodule
