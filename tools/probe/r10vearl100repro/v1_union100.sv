// v100 arm 1 — UNION and MIXED faces, in modules that TRIGGER the deleted
// drivenness route (a blocking write to a struct port / no struct port wired).
package vp1;
  typedef struct packed { logic [7:0] a; logic [7:0] b; }  net_t;   // LOOSE-net
  typedef union  packed { logic [15:0] u16; net_t us; }    upk_t;   // packed union, same width
  typedef struct packed { logic [7:0] c; upk_t d; }        withu_t; // union member
  typedef enum logic [1:0] { E0, E1 } e_t;
  typedef struct packed { logic [7:0] e; e_t f; }          var_t;   // enum member -> VAR
endpackage

// no struct port is wired at all -> pristine's undrivenStructPorts fires
module v1_undriven import vp1::*; (input net_t p_in, output net_t p_out,
                    input upk_t u_in, output upk_t u_out,
                    input withu_t w_in, output var_t v_out);
  logic [7:0] unrelated;
  always_comb unrelated = 8'h1;
endmodule

// a BLOCKING write to a struct port -> pristine's procWritesStructPort fires
module v1_procwrite import vp1::*; (input net_t p_in, output net_t p_out,
                     input upk_t u_in, output upk_t u_out,
                     output withu_t w_out, output var_t v_out);
  always_comb p_out = p_in;
  always_comb u_out = u_in;
  always_comb w_out.c = p_in.a;
  always_comb v_out = '0;
endmodule

module v1_union100 import vp1::*; ();
  net_t   a_in, a_out, b_in, b_out;
  upk_t   ua, ub, uc, ud;
  withu_t wi, wo;
  var_t   vo1, vo2;
  v1_undriven  u_und (.p_in(a_in), .p_out(a_out), .u_in(ua), .u_out(ub),
                      .w_in(wi), .v_out(vo1));
  v1_procwrite u_prc (.p_in(b_in), .p_out(b_out), .u_in(uc), .u_out(ud),
                      .w_out(wo), .v_out(vo2));
  assign a_in = '0;
  assign b_in = '0;
  assign ua   = '0;
  assign uc   = '0;
  assign wi   = '0;
endmodule
