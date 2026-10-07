// § leftoverTsCopyPerElabUse272
`include "defs.svh"
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; `MKBODY return c;
  endfunction
  localparam c_t C = mk();
endpackage
