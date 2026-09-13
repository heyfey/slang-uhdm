// r11u7 grid h1 — NESTED aggregate defaults, tagged, in every holder form.
// A: package-localparam ref (the corpus shape).  B: INLINE nested pattern.
// C: three-level nesting.  D: nested with an INSTANTIATION OVERRIDE.
package q;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
  typedef struct packed { cfg_t CFG; } top_t;
  localparam cfg_t CDEF = '{BUS: '{DAT: 32}};
  localparam cfg_t COVR = '{BUS: '{DAT: 64}};
  localparam top_t TDEF = '{CFG: '{BUS: '{DAT: 8}}};
endpackage

interface ia #(parameter q::cfg_t A = q::CDEF);           logic d; modport mp(input d); endinterface
interface ib #(parameter q::cfg_t B = '{BUS: '{DAT: 7}}); logic d; modport mp(input d); endinterface
interface ic #(parameter q::top_t C = q::TDEF);           logic d; modport mp(input d); endinterface
interface id #(parameter q::cfg_t D = q::CDEF);           logic d; modport mp(input d); endinterface

module la (ia p); logic z; assign z = p.d; endmodule
module lb (ib p); logic z; assign z = p.d; endmodule
module lc (ic p); logic z; assign z = p.d; endmodule
module ld (id p); logic z; assign z = p.d; endmodule

module top;
  ia ua(); ib ub(); ic uc(); id ud_ovr();
  la a0 (.p(ua));
  lb b0 (.p(ub));
  lc c0 (.p(uc));
  ld d0 (.p(ud_ovr));
endmodule
