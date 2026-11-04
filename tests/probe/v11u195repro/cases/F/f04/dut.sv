// § funcCfgPatOpRefBare195 — v11u195 fresh: a function whose body is a straight copy but whose struct parameter is a localparam in a two-level instance chain, two patterns
package cp;
  typedef struct packed { int unsigned XLEN; } cfg_t;
  function automatic cfg_t mk(int unsigned x); cfg_t r; r.XLEN = x; return r; endfunction
endpackage
module leaf (input logic a, output logic [7:0] o);
  localparam cp::cfg_t Cfg = cp::mk(8);
  localparam type it_t = struct packed { logic [Cfg.XLEN-1:0] S; };
  localparam it_t P1 = '{S: 8'd1};
  localparam it_t P2 = '{S: 8'd2};
  assign o = a ? P1.S : P2.S;
endmodule
module mid (input logic a, output logic [7:0] o);
  leaf u_l(.a(a), .o(o));
endmodule
module top (input logic a, output logic [7:0] o, output logic [7:0] o2);
  mid u_m(.a(a), .o(o));
  leaf u_l2(.a(a), .o(o2));
endmodule
