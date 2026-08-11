// r10oth8 arm a4 — the MODULE-SCOPE TWIN of a3, cell for cell, same names.
// a3 REFUTED the obvious predicate: golden gives an array_var NO `vpiSigned`
// when the element type is written as a TYPEDEF NAME, even a typedef of `byte`.
// a2 could not see that because it has no typedef cell — so this arm exists to
// decide whether the ALREADY-SHIPPED module-scope rule (which keys on
// `leaf->isSigned()`, i.e. on the resolved type) OVER-FIRES on a typedef'd
// element.  If it does, that is a SECOND latent defect and not this pass's
// target shape.
typedef byte              b_t;
typedef bit [7:0]         u8_t;
typedef bit signed [15:0] s16_t;
typedef int               i_t;
typedef enum { E0, E1 }   e_t;
typedef struct packed { byte hi; byte lo; } sp_t;

class ec4;
  int dummy;
endclass

module a4_top;
  b_t     c01_dyn_btd[];
  u8_t    c02_dyn_u8td[];
  s16_t   c03_dyn_s16td[];
  i_t     c04_q_itd[$];
  b_t     c05_as_btd[string];
  e_t     c06_dyn_enum[];
  sp_t    c07_dyn_struct[];
  logic signed [3:0] c08_dyn_ls[];
  byte    c09_as_bidx[e_t];
  ec4     c10_dyn_h[];
  string  c11_q_str[$];
endmodule
