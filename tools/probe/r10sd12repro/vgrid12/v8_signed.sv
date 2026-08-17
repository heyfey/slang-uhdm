// vsd12 cell v8 — THE `vpiSigned` GUARD, which the README's §2.1 files as
// UNEXERCISED.  It is not: `h1`'s `n_q` (`z1::i_t`, an INT typedef) already
// puts a SIGNED element type under a FIRING predicate, and the delivered patch
// therefore DROPS a `vpiSigned` flag it used to stamp.  This cell isolates that
// one question over every signed spelling, with the scalar twin beside it, so
// the golden answer decides whether the extended guard is right.
//
//   i_t   int                     signed
//   b_t   byte                    signed
//   ss_t  packed struct, signed   signed
//   sh_t  logic signed [7:0]      signed
//   u_t   bit [7:0]               unsigned  (control: no flag either way)
package pv8;

  class z8;                                    // LATE -> the predicate FIRES
    typedef int                             i_t;
    typedef byte                            b_t;
    typedef struct packed signed { int f; } ss_t;
    typedef logic signed [7:0]              sh_t;
    typedef bit [7:0]                       u_t;
  endclass

  class auser8;
    function void f8();
      z8::i_t  i_q[$];
      z8::i_t  i_s;
      z8::b_t  b_fx[2];
      z8::b_t  b_s;
      z8::ss_t s_q[$];
      z8::ss_t s_s;
      z8::sh_t h_q[int];
      z8::sh_t h_s;
      z8::u_t  u_q[$];
      z8::u_t  u_s;
      i_q = {};
    endfunction
  endclass

endpackage

module topv8;
  initial begin
    pv8::auser8 u = new();
    u.f8();
  end
endmodule
