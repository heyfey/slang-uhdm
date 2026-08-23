// r10v77 -- ADVERSARIAL grid C: the EXOTIC written forms around the law's
// boundary -- cross-package typedef chains, $unit spelled scoped, an UNPACKED
// struct typedef, a typedef of a packed array, signed forms, a parameterised
// width, a port DEFAULT VALUE, and a module-local typedef spelled through the
// module name.  MEASUREMENT ONLY.
package base77;
  typedef logic [7:0]  v8_t;
  typedef logic signed [7:0] sv8_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } pst_t;
endpackage

package mid77;
  import base77::*;
  typedef base77::v8_t   fwd_t;      // typedef of ANOTHER package's typedef
  typedef v8_t           impfwd_t;   // same, reached bare through the import
  typedef fwd_t [1:0]    arr_t;      // typedef of a packed array of a typedef
  typedef struct { logic [7:0] u1; logic [7:0] u2; } ust_t;   // UNPACKED struct
  typedef logic [3:0]    n4_t;
  typedef n4_t           n4alias_t;
endpackage

package pw77;
  parameter int PW = 6;
  typedef logic [PW-1:0] pwv_t;
endpackage

typedef logic [7:0] unit8_t;

module leafC (
  input  base77::v8_t     c_pv,
  output base77::v8_t     c_pvo,
  input  base77::sv8_t    c_sv,
  output base77::sv8_t    c_svo,
  input  mid77::fwd_t     c_fwd,
  output mid77::fwd_t     c_fwdo,
  input  mid77::impfwd_t  c_imf,
  output mid77::impfwd_t  c_imfo,
  input  mid77::arr_t     c_arr,
  output mid77::arr_t     c_arro,
  input  mid77::n4alias_t c_nal,
  output mid77::n4alias_t c_nalo,
  input  pw77::pwv_t      c_pw,
  output pw77::pwv_t      c_pwo,
  input  base77::pst_t    c_pst,
  output base77::pst_t    c_psto,
  input  unit8_t          c_unit,
  output unit8_t          c_unito,
  input  base77::v8_t     c_dflt = 8'hA5,
  input  logic [7:0]      c_pdflt = 8'h5A
);
  assign c_pvo  = c_pv;
  assign c_svo  = c_sv;
  assign c_fwdo = c_fwd;
  assign c_imfo = c_imf;
  assign c_arro = c_arr;
  assign c_nalo = c_nal;
  assign c_pwo  = c_pw;
  assign c_psto = c_pst;
  assign c_unito = c_unit;
endmodule

module leafD (
  input  mid77::ust_t d_ust,
  output mid77::ust_t d_usto
);
  assign d_usto = d_ust;
endmodule

module topC;
  logic [7:0] a1, a2, a3, a4, a5, a6, a7, a8, a9;
  logic [3:0] n1, n2;
  logic [5:0] p1, p2;
  logic [1:0][7:0] r1, r2;
  base77::pst_t s1, s2;
  mid77::ust_t  u1, u2;
  leafC u_c1 (.c_pv(a1), .c_pvo(a2), .c_sv(a3), .c_svo(a4),
              .c_fwd(a5), .c_fwdo(a6), .c_imf(a7), .c_imfo(a8),
              .c_arr(r1), .c_arro(r2), .c_nal(n1), .c_nalo(n2),
              .c_pw(p1), .c_pwo(p2), .c_pst(s1), .c_psto(s2),
              .c_unit(a9), .c_unito());
  leafC u_c2 ();
  leafD u_d1 (.d_ust(u1), .d_usto(u2));
endmodule
