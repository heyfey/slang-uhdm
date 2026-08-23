// r10earl77 -- the BOUNDARY arm for the port-kind law: the net-keyword form,
// the `var` form, the INOUT direction, NON-ANSI ports (the only style in which
// a MODULE-LOCAL typedef can type a port), and an interface port as a control.
// MEASUREMENT ONLY.
package q77;
  typedef logic [7:0]      v8_t;
  typedef enum logic [1:0] { Q770, Q771 } e_t;
endpackage

interface if77;
  logic [7:0] d;
  modport mp (input d);
endinterface

module kw77 (
  input  wire q77::v8_t k_wirein,
  output wire q77::v8_t k_wireout,
  input  var  q77::v8_t k_varin,
  output var  q77::v8_t k_varout,
  input       q77::v8_t k_plainin,
  output      q77::v8_t k_plainout
);
  assign k_wireout  = k_wirein;
  assign k_varout   = k_varin;
  assign k_plainout = k_plainin;
endmodule

module io77 (
  inout  q77::v8_t   g_plainio,
  inout  wire q77::v8_t g_wireio,
  inout  logic [7:0] g_logicio,
  inout  wire [7:0]  g_wirevecio
);
endmodule

module na77 (na_pkgin, na_impin, na_locin, na_barein, na_pkgout, na_locout);
  import q77::*;
  typedef logic [7:0] loc77_t;
  input  q77::v8_t na_pkgin;
  input  v8_t      na_impin;
  input  loc77_t   na_locin;
  input  [7:0]     na_barein;
  output q77::v8_t na_pkgout;
  output loc77_t   na_locout;
  assign na_pkgout = na_pkgin;
  assign na_locout = na_locin;
endmodule

module ifp77 (
  if77.mp     p_if,
  input q77::v8_t p_pkgin
);
endmodule

module topq77;
  logic [7:0] wi, wo, vi, vo, pi, po;
  kw77 u_kw (.k_wirein(wi), .k_wireout(wo), .k_varin(vi), .k_varout(vo),
             .k_plainin(pi), .k_plainout(po));
  wire [7:0] z1, z2, z3, z4;
  io77 u_io (.g_plainio(z1), .g_wireio(z2), .g_logicio(z3), .g_wirevecio(z4));
  logic [7:0] n1, n2, n3, n4, n5, n6;
  na77 u_na (.na_pkgin(n1), .na_impin(n2), .na_locin(n3), .na_barein(n4),
             .na_pkgout(n5), .na_locout(n6));
  if77 u_ifi ();
  logic [7:0] q1;
  ifp77 u_ifp (.p_if(u_ifi.mp), .p_pkgin(q1));
endmodule
