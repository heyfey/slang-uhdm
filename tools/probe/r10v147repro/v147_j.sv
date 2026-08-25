// r10uvm147 VERIFIER grid J — the INDEX-SHAPE faces the briefing names that
// the implementer's grid D does not reach: a function CALL index, a member
// select index, a ternary index, a concatenation index, a string key, a
// SIGNED/enum index, and a `-:` trailing range on the newly admitted bases.
package q147vj;
  typedef enum int { E0 = 0, E1 = 1 } ej147_t;
  typedef struct { logic [63:0] arr[4]; } sj147_t;
  localparam sj147_t PJ = '{arr:'{64'h1,64'h2,64'h3,64'h4}};

  class cj147;
    logic [63:0] dyn[];
    logic [63:0] asc[string];
    int          ix[8];
    sj147_t      s;
    function int f(int a); return a; endfunction
  endclass

  class uj147;
    cj147 hp;
    int   mi;
    function void g(cj147 fa, sj147_t fs, int idx, int i, ej147_t e);
      logic [7:0] o;
      o = fa.dyn[fa.f(i)][8*i +: 8];        // j01 CALL index, formal receiver
      o = fa.dyn[fa.s.arr[0]][8*i +: 8];    // j02 member-select index
      o = fa.dyn[(i > 0) ? idx : 0][8*i+:8];// j03 ternary index
      o = fa.dyn[fa.ix[fa.ix[i]]][8*i+:8];  // j04 doubly nested select index
      o = fa.asc["key"][8*i +: 8];          // j05 STRING key, formal receiver
      o = fa.dyn[int'(e)][8*i +: 8];        // j06 enum-cast index
      o = fa.dyn[idx][8*i+7 -: 8];          // j07 `-:` on a formal receiver
      o = fs.arr[idx][8*i+7 -: 8];          // j08 `-:` on a struct formal
      o = PJ.arr[idx][8*i+7 -: 8];          // j09 `-:` on a localparam base
      o = fa.dyn[idx][{2'b0, i[5:0]} +: 8]; // j10 concatenation as the base
      o = fa.s.arr[fa.f(i)][8*i +: 8];      // j11 member chain + call index
    endfunction
    // the CONTROL twins on a LOCAL VARIABLE receiver — must not move.
    function void gctl(int idx, int i);
      cj147 lv;
      logic [7:0] o;
      o = lv.dyn[lv.f(i)][8*i +: 8];        // j21
      o = lv.dyn[lv.ix[lv.ix[i]]][8*i+:8];  // j22
      o = lv.asc["key"][8*i +: 8];          // j23
      o = lv.dyn[idx][8*i+7 -: 8];          // j24
    endfunction
  endclass
endpackage
