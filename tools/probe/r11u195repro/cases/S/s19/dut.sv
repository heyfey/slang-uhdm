// § funcCfgPatOpRefBare195 — grid S/s19 (r11u195)
package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t mk(int unsigned x); cfg_t r; r.XLEN = x; return r; endfunction
endpackage
module child #(parameter cp::cfg_t Cfg = '{XLEN: 32'd4}) (input logic a, output logic [7:0] o);
  localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] S; logic [Cfg.XLEN-1:0] M; };
  localparam it_t INT = '{S: 1, M: 3};
  assign o = a ? INT.S : INT.M;
endmodule
module top(input logic a, output logic [7:0] o);
  child #(.Cfg(cp::mk(6))) u(.a(a), .o(o));
endmodule
