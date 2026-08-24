// r10vbuvm34repro/v34a.sv — VERIFIER ARM A: the NON-CLASS `::` faces.
// scopedArr33 fires on ANY `::`-written base, not only a class scope.  This
// arm asks golden what a PACKAGE-qualified and a `$unit::`-qualified array
// reference does to the loop variable, over the resolvable table, in four
// homes.  MEASUREMENT ONLY.
package pv34;
  typedef enum bit [2:0] { PE0 = 0, PE1 = 1 } pe34_t;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } psp34_t;
  typedef int pta34_t[4];
  class pkey34; int k; endclass

  int      pq34 [$];          // queue of int
  int      pd34 [];           // dynamic of int
  int      pf34 [4];          // fixed of int
  string   ps34 [$];          // queue of string
  pkey34   pc34 [$];          // queue of class handles
  int      pa34 [string];     // associative [string]
  int      pi34 [int];        // associative [int]
  int      px34 [pkey34];     // associative [class]
  pe34_t   pe34q[$];          // queue of enum
  psp34_t  pp34 [$];          // queue of packed struct
  bit [7:0] pv34v;            // PACKED vector
  int      pm34 [3][4];       // multi-dim fixed
  pta34_t  pt34;              // typedef'd fixed array

  function void pfn34();
    int r;
    foreach (pv34::pq34 [i]) r = i;      // PF1  pkg::queue<int>
    foreach (pv34::pd34 [i]) r = i;      // PF2
    foreach (pv34::pf34 [i]) r = i;      // PF3
    foreach (pv34::ps34 [i]) r = i;      // PF4  pkg::queue<string>
    foreach (pv34::pc34 [i]) r = i;      // PF5  pkg::queue<class>
    foreach (pv34::pa34 [i]) r = 1;      // PF6  pkg::assoc[string]
    foreach (pv34::pi34 [i]) r = i;      // PF7  pkg::assoc[int]
    foreach (pv34::px34 [i]) r = 1;      // PF8  pkg::assoc[class]
    foreach (pv34::pe34q[i]) r = i;      // PF9  pkg::queue<enum>
    foreach (pv34::pp34 [i]) r = i;      // PF10 pkg::queue<packed struct>
    foreach (pv34::pv34v[i]) r = i;      // PF11 pkg::PACKED vector
    foreach (pv34::pm34 [i,j]) r = i+j;  // PF12 pkg::multi-dim
    foreach (pv34::pt34 [i]) r = i;      // PF13 pkg::typedef'd fixed
    // bare controls in the SAME function
    foreach (pq34 [i]) r = i;            // PB1
    foreach (pd34 [i]) r = i;            // PB2
    foreach (pf34 [i]) r = i;            // PB3
    foreach (ps34 [i]) r = i;            // PB4
    foreach (pc34 [i]) r = i;            // PB5
    foreach (pa34 [i]) r = 1;            // PB6
    foreach (pi34 [i]) r = i;            // PB7
    foreach (px34 [i]) r = 1;            // PB8
    foreach (pe34q[i]) r = i;            // PB9
    foreach (pp34 [i]) r = i;            // PB10
    foreach (pv34v[i]) r = i;            // PB11
    foreach (pm34 [i,j]) r = i+j;        // PB12
    foreach (pt34 [i]) r = i;            // PB13
  endfunction

  task ptk34();
    int r;
    foreach (pv34::pq34[i]) r = i;       // PT1 package TASK, scoped
    foreach (pq34[i])       r = i;       // PT2 package TASK, bare
    foreach (pv34::pa34[i]) r = 1;       // PT3 package TASK, scoped assoc
    foreach (pa34[i])       r = 1;       // PT4 package TASK, bare assoc
  endtask
endpackage

module mv34a;
  import pv34::*;
  int rm;
  initial begin
    foreach (pv34::pq34[i]) rm = i;      // MM1 module, pkg::queue
    foreach (pv34::pa34[i]) rm = 1;      // MM2 module, pkg::assoc[string]
    foreach (pv34::px34[i]) rm = 1;      // MM3 module, pkg::assoc[class]
    foreach (pv34::ps34[i]) rm = i;      // MM4 module, pkg::queue<string>
    foreach (pv34::pv34v[i]) rm = i;     // MM5 module, pkg::packed vector
    foreach (pq34[i])       rm = i;      // MB1 module, bare
    foreach (pa34[i])       rm = 1;      // MB2 module, bare assoc
  end
endmodule
