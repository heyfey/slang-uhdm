// r10v188repro/arms/v188_a_render.sv — ADVERSARIAL RENDER FACES.
// MEASUREMENT ONLY.  LHS is always golden (Surelog); RHS is always ours.
// Every operator of the modelled set, every spacing spelling, redundant
// parentheses in every position, and nesting to three levels.  Values are all
// distinct so no enum-member collision can hide a row.
package v188a_pkg;
  typedef enum {
    A_ADD   = 1 + 2,
    A_SUB   = 9 - 3,
    A_MUL   = 3 * 5,
    A_DIV   = 40 / 4,
    A_SHL   = 1 << 6,
    A_SHR   = 256 >> 3,
    A_SP0   = 7+11,
    A_SP1   = 7 +12,
    A_SP2   = 7+ 13,
    A_SP3   = 7  +  14,
    A_PAR0  = (1 << 8),
    A_PAR1  = ((1) << (9)),
    A_PAR2  = (2 + 3) * 5,
    A_PAR3  = 2 + (3 * 5) + 9,
    A_NEST  = 1 + 2 + 4,
    A_NEST2 = 100 - 10 - 5,
    A_NEST3 = 2 * 3 * 7,
    A_MIX   = 1 + 2 * 11,
    A_SHLN  = 3 << 2 << 3
  } v188a_e;
endpackage
