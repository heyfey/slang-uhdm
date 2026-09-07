// r10uvm188 — ARM c: ORDER, CASE, WHITESPACE, PARENTHESES and the UNSIZED
// BASED literal, in every operand position.
// An arm that agrees with golden is not an arm that TESTS the law: this one
// writes the shapes in a different listing order, in mixed case, with and
// without interior spaces and with redundant parentheses, at shift counts that
// make the modelled size (lhs bits +/- the shift VALUE) unmistakable, and puts
// an UNSIZED based literal ('h..., width-indeterminate, Surelog size 0) on the
// left, on the right and inside an addition.
package cor;
  typedef enum {
    C_Z  =  ( ( 1 ) )  ,
    c_y  = 1<<1,
    C_x  = 1 <<  2,
    c_W  = ((1) << (3)),
    C_t  = 1024 >> 2,
    c_S  = 'h1 << 12,
    C_r  = 4'h1 << 13,
    c_Q  = 'h3 + 40,
    C_p  = 40 + 'h4,
    c_O  = 'h50 - 1,
    C_n  = 'h60 * 3,
    c_M  = 12'h700 >> 1,
    C_l  = 1 - 2 + 1000,
    c_K  = 2 * 3 * 77,
    C_j  = 100 / 4 / 5,
    // BOTH leaves UNSIZED based: Surelog gives each a size of ZERO, so the
    // modelled `max(a,b)` size is 0 too — the one place the law can produce a
    // size that is neither 64 nor a written width.
    c_I  = 'h1 + 'h2,
    C_H  = 'h9 + 'h3
  } cor_e;
  // The 33- and 40-bit shifts need a base wide enough to HOLD them: an
  // implicit `int` enum truncates them both to 0 and slang rejects the
  // duplicate.  Golden's render does not depend on the base (arm a), so the
  // wide base is free — and it doubles as a second base under this arm's law.
  typedef enum bit [63:0] {
    C_v  = 1 << 33,
    c_U  = 1 << 40,
    C_h  = 1 << 63,
    c_G  = 64'h1 << 2
  } cor_wide_e;
endpackage
module corm;
  cor::cor_e z0;
  initial z0 = cor::C_x;
endmodule
