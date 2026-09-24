// vbuvm7 arm O — PARTIAL macro expansion inside the lvalue, comments, spacing.
`define BASEO(a,i) a[i]
`define MEMO used
typedef struct { int used; } stO_t;
class holdO;
  stO_t q[$];
  int i;
  function void f();
    i = 0;
    `BASEO(q,i).used++;          // O1 base from a MACRO, member in source
    q[i].`MEMO++;                // O2 member from a MACRO
    q [ i ] . used ++;           // O3 loose spacing
    q[i]/*c*/.used++;            // O4 comment inside the lvalue
  endfunction
endclass
module topO; initial begin end endmodule
