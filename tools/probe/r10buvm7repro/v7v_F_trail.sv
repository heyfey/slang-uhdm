// vbuvm7 adversarial arm F — TRAILING selects (R2, must NOT move) + nested.
typedef struct { int ai[4]; logic [7:0] v; int used; } stF_t;
typedef struct { stF_t inner[2]; int used; } outF_t;
class holdF;
  stF_t q[$];
  outF_t oq[$];
  function void f();
    int i; i = 0;
    q[i].ai[1]++;               // F1 trailing bit select   (residue)
    q[i].v[3:0]++;              // F2 trailing part select  (residue)
    q[i].v[1+:2]++;             // F3 trailing indexed part select (residue)
    q[i].v[2-:2]++;             // F4 trailing indexed part select down
    oq[i].inner[1].used++;      // F5 select in the MIDDLE, member last
    oq[i].inner[1].ai[0]++;     // F6 middle select AND trailing select
    q[i].used++;                // F7 control: collapses
  endfunction
endclass
module topF; initial begin end endmodule
