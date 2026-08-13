// r10uvm73 VERIFIER arm v3 — WHAT ACTUALLY SIZES THE CONSTANT ON A DEGRADED
// PROPERTY.  The shipped law says "sized 64"; v2 already showed 96 and 4.
// This arm separates the two candidate carriers that v2 could not:
//   (a) the PROPERTY's width  (what pristine emits)
//   (b) the LITERAL's own written width, with 64 for an UNSIZED literal
// by making them DISAGREE: a 96-bit property initialised with a 4-bit literal
// and a 4-bit property initialised with a 32-bit one.
package p1;
  class holder;
    typedef int        i_t;
    typedef bit [95:0] w_t;
    typedef bit [3:0]  n_t;
  endclass

  class sizee;
    holder::i_t c_uns    = 7;       // unsized  literal, 32-bit property
    holder::w_t c_uns96  = 7;       // unsized  literal, 96-bit property
    holder::n_t c_uns4   = 7;       // unsized  literal,  4-bit property
    holder::w_t c_mix_w4 = 4'd7;    // 4-bit  literal in a 96-bit property
    holder::n_t c_mix_4w = 4'd7;    // 4-bit  literal in a  4-bit property
    holder::i_t c_sz32   = 32'd7;   // 32-bit literal in a 32-bit property
    holder::i_t c_sz8    = 8'd7;    // 8-bit  literal in a 32-bit property
  endclass

  class szctl;                       // CONTROLS: own-class typedefs
    typedef int        i_t;
    typedef bit [95:0] w_t;
    typedef bit [3:0]  n_t;
    i_t k_uns    = 7;
    w_t k_uns96  = 7;
    n_t k_uns4   = 7;
    w_t k_mix_w4 = 4'd7;
    n_t k_mix_4w = 4'd7;
    i_t k_sz32   = 32'd7;
    i_t k_sz8    = 8'd7;
  endclass
endpackage

module top;
  p1::sizee s; p1::szctl k;
  initial begin s = new(); k = new(); end
endmodule
