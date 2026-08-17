// r10uvm81 VERIFIER arm E — LAW 2 (§ selIdxNestPrefixJoinsByScope80) at the
// joints the brief names and c3 does NOT reach: DEPTH 5/6, part-select and
// indexed-part-select INDICES, a PACKAGE-QUALIFIED base, a `this.`-qualified
// base, a class-property base, a queue / dynamic-array / associative base, an
// index that is itself a hierarchical path, and the module twin of every one.
package pe95;
  int qarr [4];
endpackage

class leaf95; int f; endclass

class deep95;
  leaf95 iarr[8];
  int    midx[8];
  int    i, j;
  int    q[$];
  int    dyn[];
  int    asc[string];
  bit [31:0] w;
  bit [31:0] warr [4];
  leaf95 self_arr[4];
  function int fn95(int a); return a; endfunction

  function int probe95();
    int r;
    // ---- DEPTH beyond c3's 4 -------------------------------------------
    r = iarr[midx[midx[midx[midx[midx[i]]]]]].f;        // e1 DEPTH 5
    r = iarr[midx[midx[midx[midx[midx[midx[i]]]]]]].f;  // e2 DEPTH 6

    // ---- PART-SELECT and INDEXED PART-SELECT indices --------------------
    r = warr[midx[midx[i]]][7:0];                       // e3 range sel of nested idx
    r = warr[midx[midx[i]]][midx[i] +: 4];              // e4 indexed part-select
    r = warr[midx[midx[i]]][midx[midx[i]] -: 4];        // e5 nested idx IN the psel
    r = w[midx[midx[i]] +: 4];                          // e6 nested idx as psel base

    // ---- QUALIFIED bases ------------------------------------------------
    r = pe95::qarr[midx[midx[i]]];                      // e7 PACKAGE-qualified base
    r = this.iarr[midx[midx[i]]].f;                     // e8 `this.`-qualified base
    r = self_arr[midx[midx[i]]].f;                      // e9 class-property base

    // ---- non-fixed-size bases -------------------------------------------
    r = q[midx[midx[i]]];                               // e10 QUEUE base
    r = dyn[midx[midx[i]]];                             // e11 DYNAMIC ARRAY base

    // ---- LVALUES at the same joints -------------------------------------
    warr[midx[midx[i]]][7:0] = 8'h1;                    // e12 lvalue range sel
    q[midx[midx[i]]] = 1;                               // e13 lvalue queue
    this.iarr[midx[midx[i]]].f = 2;                     // e14 lvalue this-qualified

    // ---- CALL ARGUMENTS at the same joints ------------------------------
    r = fn95(warr[midx[midx[i]]][7:0]);                 // e15
    r = fn95(pe95::qarr[midx[midx[i]]]);                // e16
    r = fn95(this.iarr[midx[midx[i]]].f);               // e17

    // ---- index that is an OPERATION over a nested select -----------------
    r = iarr[midx[midx[i]] + midx[j]].f;                // e18
    r = iarr[fn95(midx[midx[i]])].f;                    // e19
    return r;
  endfunction
endclass

// ---- the MODULE twin of every cell: joinRef must return `.` throughout ----
module mdeep95;
  typedef struct { int f; } st95;
  st95 sarr[8];
  int  mi[8];
  int  z;
  bit [31:0] mw;
  bit [31:0] mwarr [4];
  int  mq[$];
  function int mfn95(int a); return a; endfunction
  initial begin
    z = sarr[mi[mi[mi[mi[mi[z]]]]]].f;                  // f1  depth 5
    z = sarr[mi[mi[mi[mi[mi[mi[z]]]]]]].f;              // f2  depth 6
    z = mwarr[mi[mi[z]]][7:0];                          // f3
    z = mwarr[mi[mi[z]]][mi[z] +: 4];                   // f4
    z = mwarr[mi[mi[z]]][mi[mi[z]] -: 4];               // f5
    z = mw[mi[mi[z]] +: 4];                             // f6
    z = pe95::qarr[mi[mi[z]]];                          // f7 package base in a MODULE
    z = mq[mi[mi[z]]];                                  // f10
    mwarr[mi[mi[z]]][7:0] = 8'h1;                       // f12
    mq[mi[mi[z]]] = 1;                                  // f13
    z = mfn95(mwarr[mi[mi[z]]][7:0]);                   // f15
    z = sarr[mi[mi[z]] + mi[z]].f;                      // f18
    z = sarr[mfn95(mi[mi[z]])].f;                       // f19
  end
endmodule
