// § funcCfgPatNamedOnly195v — v11u195 fresh: the parameter in a module with a macro-born struct dimension and a positional pattern
`define W(c) c.XLEN-1:0
package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t mk(int unsigned x); cfg_t r; r.XLEN = x; return r; endfunction
endpackage
module top #(parameter cp::cfg_t Cfg = cp::mk(8)) (input logic a, output logic [7:0] o);
  localparam type it_t = struct packed { logic [`W(Cfg)] S; logic [`W(Cfg)] M; };
  localparam it_t INT = '{1, 3};
  assign o = a ? INT.S : INT.M;
endmodule
