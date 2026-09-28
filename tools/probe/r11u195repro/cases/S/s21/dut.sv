// § funcCfgPatOpRefBare195 — grid S/s21 (r11u195)
package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t mk(int unsigned x); cfg_t r; r.XLEN = x; return r; endfunction
endpackage
module leaf #(parameter cp::cfg_t Cfg = cp::mk(4)) (input logic a, output logic [7:0] o);
  localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] S; logic [Cfg.XLEN-1:0] M; };
  localparam it_t INT = '{S: 1, M: 3};
  assign o = a ? INT.S : INT.M;
endmodule
module mid(input logic a, output logic [7:0] o, output logic [7:0] p);
  leaf u1(.a(a), .o(o));
  leaf u2(.a(a), .o(p));
endmodule
module top(input logic a, output logic [7:0] o, output logic [7:0] p);
  mid m(.a(a), .o(o), .p(p));
endmodule
