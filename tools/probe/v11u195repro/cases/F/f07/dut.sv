// § funcCfgPatOpRefBare195 — v11u195 fresh: the s15 shape in a child instance at depth 2 and 3 with two patterns per instance
package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t mk(int unsigned x); cfg_t r; r.XLEN = x; return r; endfunction
endpackage
module leaf #(parameter cp::cfg_t Cfg = cp::mk(8)) (input logic a, output logic [7:0] o);
  localparam int X = Cfg.XLEN;
  localparam type it_t = struct packed { logic [X-1:0] S; logic [X-1:0] M; };
  localparam it_t INT = '{S: 1, M: 3};
  localparam it_t INU = '{S: 2, M: 4};
  assign o = a ? INT.S : INU.M;
endmodule
module mid (input logic a, output logic [7:0] o);
  leaf u_l (.a(a), .o(o));
endmodule
module top (input logic a, output logic [7:0] o, output logic [7:0] o2);
  mid u_m (.a(a), .o(o));
  leaf u_k (.a(a), .o(o2));
endmodule
