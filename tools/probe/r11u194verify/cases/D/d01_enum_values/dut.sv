// § enumConstUnderscoreDropped186: enum values written 1_0, 1_000_000, a sized decimal 16'd2_5 and a long bare decimal, in a module enum and a package enum read through an import
package p;
  typedef enum longint { PA = 1_000_000, PB = 1_000_000_000, PC } pe_t;
endpackage
module top (output int o, output longint q);
  import p::*;
  typedef enum int { A = 1_0, B = 1_000_000, C = 32'd2_5, D } e_t;
  e_t v;
  pe_t w;
  assign o = (v == B) ? 1 : 0;
  assign q = w;
endmodule
