// r10buvm7 arm v1 — § lvIncDecSelMemberCollapse7's SHAPE grid.
// One inc/dec statement per cell.  LHS is ALWAYS golden(Surelog).
// Read with: r10buvm7cen <db> <tag>  (one INCDEC row per cell, keyed line:col)
package p7;
typedef struct { int used; int c; logic [7:0] v; int ai[4]; } st_t;
typedef struct { st_t inner; int used; } outer_t;
class inner7;
  int  used;
  st_t s;
  st_t sq[$];
  int  iq[$];
endclass
class holder7;
  st_t    sq[$];        // queue of struct
  st_t    sd[];         // dynamic array of struct
  st_t    sa[4];        // fixed array of struct
  st_t    sm[string];   // associative array of struct
  st_t    s2[2][2];     // two dimensions
  outer_t oq[$];        // depth-2 member chain
  inner7  cq[$];        // queue of CLASS HANDLES
  int     iq[$];        // queue of ints (no member)
  inner7  ch;           // class handle
  st_t    sbare;        // plain struct
  int     r;
  function void f1();
    int index; index = 0;
    sq[index].used++;          // a1  COLLAPSE  queue-of-struct, var index
    sq[0].used++;              // a2  COLLAPSE  constant index
    sd[index].used++;          // a3  COLLAPSE  dynamic array
    sa[index].used++;          // a4  COLLAPSE  fixed array
    sm["k"].used++;            // a5  COLLAPSE  associative array
    s2[index][1].used++;       // a6  COLLAPSE  two index dimensions
    oq[index].inner.used++;    // a7  COLLAPSE  member depth 2
    cq[index].used++;          // a8  COLLAPSE  class-handle element
    ch.s.used++;               // a9  hier_path  first id has NO bracket
    sbare.used++;              // a10 hier_path  first id has NO bracket
    iq[index]++;               // a11 bit_select nothing to drop
    index++;                   // a12 ref_obj
    --sq[index].used;          // a13 COLLAPSE  PREFIX
    sq[index].used--;          // a14 COLLAPSE  postfix decrement
    r = sq[index].used++;      // a15 COLLAPSE  inside an EXPRESSION
    sq[index].c++;             // a16 COLLAPSE  a different member
    ch.iq[index]++;            // b1  hier_path  member then select
    ch.sq[index].used++;       // b2  hier_path  member, select, member
    ch.s.ai[index]++;          // b3  hier_path  member, member, select
    sq[index].ai[1]++;         // b5  RESIDUE    trailing bracket -> bit_select
    sq[index].v[3:0]++;        // b5b RESIDUE    trailing range   -> part_select
    sq[index].used = 5;        // b6  hier_path  ASSIGNMENT, not inc/dec
    sq[index].used += 2;       // b6b hier_path  compound assignment
    r = sq[index].used;        // b6c hier_path  rvalue
    if (sq[index].used == 3) r = 1;  // b6d hier_path  if condition
  endfunction
  task t1();
    int index; index = 0;
    sq[index].used++;                     // b7  COLLAPSE in a task
    for (int i=0;i<2;i++) sq[i].used++;   // b8  COLLAPSE in a for body
    fork sq[index].used++; join_none      // b9  COLLAPSE in a fork
    foreach (sq[j]) sq[j].used++;         // b10 COLLAPSE in a foreach
  endtask
endclass
endpackage
module m7;
  import p7::*;
  st_t sa[4];
  int  ia[4];
  initial begin
    sa[1].used++;              // b11 COLLAPSE module-scope initial
    ia[1]++;                   // b12 bit_select
  end
  always @(*) sa[2].used++;    // b13 COLLAPSE in an always
endmodule
