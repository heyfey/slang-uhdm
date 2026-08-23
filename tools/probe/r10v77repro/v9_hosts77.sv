// r10v77 -- ADVERSARIAL grid I: unusual HOSTS and unusual TYPES.
// A module instantiated inside an INTERFACE and inside a PROGRAM, a BIND
// instance, an UNPACKED-ARRAY package typedef port, and `default_nettype none`.
`default_nettype none
package i77;
  typedef logic [7:0] v8_t;
  typedef logic [7:0] ua_t [0:3];     // UNPACKED array typedef
endpackage

module leafI (
  input  i77::v8_t k_pv,
  output i77::v8_t k_pvo
);
  assign k_pvo = k_pv;
endmodule

module leafU (
  input  i77::ua_t u_pv,
  output i77::ua_t u_pvo
);
  assign u_pvo = u_pv;
endmodule

interface ifI;
  logic [7:0] x, y;
endinterface

program prgI;
  logic [7:0] px, py;
endprogram

module victimI;
  logic [7:0] vx, vy;
endmodule

module topI;
  logic [7:0] a, b;
  i77::ua_t   ua, ub;
  leafI  u_i (.k_pv(a), .k_pvo(b));
  leafU  u_u (.u_pv(ua), .u_pvo(ub));
  ifI    u_ifi ();
  prgI   u_prg ();
  victimI u_v ();
endmodule

bind victimI leafI u_bound (.k_pv(vx), .k_pvo(vy));
`default_nettype wire
