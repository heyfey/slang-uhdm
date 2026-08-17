// vbuvm7 adversarial arm D — MEMBER exotica: unions, depth 3, packed.
typedef struct packed { logic [7:0] pa; logic [7:0] pb; } pk_t;
typedef union { int ua; logic [31:0] ub; } un_t;
typedef struct { int lvl3; } d3_t;
typedef struct { d3_t mid; int used; } d2_t;
typedef struct { d2_t top; } d1_t;
class holdD;
  un_t  uq[$];
  pk_t  pq[$];
  d1_t  dq[$];
  function void f();
    int i; i = 0;
    uq[i].ua++;                 // D1 UNION member
    pq[i].pa++;                 // D2 PACKED-struct member
    dq[i].top.mid.lvl3++;       // D3 member depth THREE
    dq[i].top.used++;           // D4 member depth two (control)
  endfunction
endclass
module topD;
  un_t  ua[4];
  pk_t  pa[4];
  initial begin
    ua[1].ua++;                 // D5 union, module scope
    pa[1].pb++;                 // D6 packed, module scope
  end
endmodule
