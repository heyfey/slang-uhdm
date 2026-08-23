// r10v77 -- ADVERSARIAL grid E: NON-ANSI port declarations of every shape,
// including a module-LOCAL typedef (only legal non-ANSI), a body redeclaration
// of a scoped-typedef port, and a scoped typedef reached through an import.
package e77;
  typedef logic [7:0] v8_t;
  typedef enum logic [1:0] { E770, E771 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } st_t;
endpackage

module naE (na_pv, na_pvo, na_io, na_imp, na_loc, na_pe, na_pst, na_re, na_body);
  import e77::*;
  typedef logic [7:0] loc_t;
  input  e77::v8_t na_pv;
  output e77::v8_t na_pvo;
  inout            na_io;
  wire e77::v8_t   na_io_w;
  input  v8_t      na_imp;
  input  loc_t     na_loc;
  input  e77::e_t  na_pe;
  input  e77::st_t na_pst;
  input  reg [7:0] na_re;
  input            na_body;
  e77::v8_t        na_body;      // NON-ANSI body declaration typed by a scoped typedef
  assign na_pvo = na_pv;
endmodule

module topE;
  logic [7:0] a, b, c, d, e, f;
  e77::e_t  ee;
  e77::st_t ss;
  wire [7:0] z;
  naE u_e (.na_pv(a), .na_pvo(b), .na_io(z), .na_imp(c), .na_loc(d),
           .na_pe(ee), .na_pst(ss), .na_re(e), .na_body(f));
endmodule
