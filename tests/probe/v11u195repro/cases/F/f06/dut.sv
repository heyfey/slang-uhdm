// § funcCfgPatDeclScope195v — v11u195 fresh: control of f05, the module's parameter named Y (no shadowing name)
package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t mk(int unsigned x); cfg_t r; r.XLEN = x; return r; endfunction
  localparam int X = 8;
  typedef struct packed { logic [X-1:0] S; logic [X-1:0] M; } it_t;
endpackage
module top #(parameter cp::cfg_t Cfg = cp::mk(8)) (input logic a, output logic [7:0] o);
  localparam int Y = Cfg.XLEN;
  localparam cp::it_t INT = '{S: 1, M: 3};
  assign o = a ? INT.S : INT.M;
endmodule
