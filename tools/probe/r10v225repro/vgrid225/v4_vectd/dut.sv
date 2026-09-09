// r10v225 arm v4_vectd — R-B's SPLIT, both sides of the instantiation
// discriminator, over EVERY vector-typedef spelling `vectorTypedefElem225`
// answers true for (`reg`, `bit`, `logic`, a scalar alias, a chained alias) and
// the ones it answers false for.  The `reg` spelling is the sharp one: golden's
// net type for a `reg`-spelled alias is vpiReg(48) elsewhere, not 36.
typedef reg   [1:0] tr225_t;
typedef bit   [1:0] tb225_t;
typedef logic [1:0] tl225_t;
typedef logic       ts225_t;      // scalar alias
typedef tl225_t     tc225_t;      // chained alias
typedef struct packed { logic a; logic b; } tsp225_t;

interface if225v_un();
  typedef int tint225_t;
  tr225_t u_reg   [1:0];
  tb225_t u_bit   [1:0];
  tl225_t u_log   [1:0];
  ts225_t u_scal  [1:0];
  tc225_t u_chain [1:0];
  tint225_t u_int [1:0];
  tsp225_t u_sp   [1:0];
  tr225_t u_regd  [];
  tb225_t u_bitq  [$];
  tl225_t u_loga  [string];
endinterface

interface if225v_in();
  typedef int nint225_t;
  tr225_t n_reg   [1:0];
  tb225_t n_bit   [1:0];
  tl225_t n_log   [1:0];
  ts225_t n_scal  [1:0];
  tc225_t n_chain [1:0];
  nint225_t n_int [1:0];
  tsp225_t n_sp   [1:0];
  tr225_t n_regd  [];
  tb225_t n_bitq  [$];
  tl225_t n_loga  [string];
endinterface

module top225v_vt();
  if225v_in u_in();
endmodule
