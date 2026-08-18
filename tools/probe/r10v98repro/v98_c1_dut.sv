// v98_c1 — H1: does the FIRST-writer registration really key on the typedef's
// own bare name when the typedef's TARGET is another typedef?
package p98v;
  class aaa98v;                   // alphabetically FIRST declarer of rank_t
    typedef int      seed_t;
    typedef seed_t   rank_t;      // target is a TYPEDEF, not a builtin
    function void own_a(rank_t x); endfunction
  endclass
  class bbb98v;                   // the BASE the reference really inherits from
    typedef bit [7:0] rank_t;
    function void own_b(rank_t x); endfunction
  endclass
  class ccc98v extends bbb98v;    // reference site: INHERITED bare name
    function void hot_c(rank_t x); endfunction
    function void hot_l(); rank_t loc; loc = 0; endfunction
  endclass
endpackage
module top98v;
  import p98v::*;
  ccc98v c;
  initial c = new();
endmodule
