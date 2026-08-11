// r10oth8 arm a5 — the BOUNDARY arm for the refuted-and-replaced predicate.
// a3/a4 showed golden keys `vpiSigned` on the element type AS WRITTEN, not on
// the resolved type: a typedef NAME gets nothing even when it names `byte`.
// This arm pins the boundary of "as written" with the cases a `kind !=
// TypeAlias` test could still get wrong, and it carries the CLASS half (`d*`)
// and the MODULE half (`e*`) of every cell in ONE Surelog run so the two scopes
// can never be measured against different golden databases.
typedef byte  b_t;
typedef b_t   b2_t;          // a typedef CHAIN
typedef byte  barr_t[];      // the whole ARRAY through a typedef
typedef byte  bq_t[$];

class dc;
  // inline ANONYMOUS aggregates: NOT type aliases in slang, so a
  // `kind != TypeAlias` test lets them through — golden decides whether that
  // is right.
  rand enum { DA, DB }              d01_dyn_anonenum[];
  rand struct packed { byte a; }    d02_dyn_anonstruct[];
  // a typedef CHAIN of a signed type
  rand b2_t                         d03_dyn_chain[];
  // the ARRAY itself typedef'd (the element is never written at the declarator)
  rand barr_t                       d04_arrtd;
  rand bq_t                         d05_qtd;
  // a CLASS-LOCAL typedef of a signed type
  typedef byte lb_t;
  rand lb_t                         d06_dyn_localtd[];
  // multi-dimension PACKED element, signed and unsigned
  rand bit signed [7:0][3:0]        d07_dyn_pk2s[];
  rand bit        [7:0][3:0]        d08_dyn_pk2u[];
  // a signed packed STRUCT written inline
  rand struct packed signed { byte a; } d09_dyn_spsigned[];
  // shortreal / real: not signed, not integral
  shortreal                         d10_dyn_shortreal[];
endclass

module a5_top;
  enum { EA, EB }               e01_dyn_anonenum[];
  struct packed { byte a; }     e02_dyn_anonstruct[];
  b2_t                          e03_dyn_chain[];
  barr_t                        e04_arrtd;
  bq_t                          e05_qtd;
  byte                          e06_dyn_localtd[];   // no local typedef here
  bit signed [7:0][3:0]         e07_dyn_pk2s[];
  bit        [7:0][3:0]         e08_dyn_pk2u[];
  struct packed signed { byte a; } e09_dyn_spsigned[];
  shortreal                     e10_dyn_shortreal[];
  dc dh;
  initial dh = new();
endmodule
