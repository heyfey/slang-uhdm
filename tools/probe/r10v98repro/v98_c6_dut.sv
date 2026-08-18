// v98_c6 — QUALIFIED spellings must stay correct next to a bare one.
package p6v;
  class a6win98v;
    typedef bit [6:0] qk6_t;
  endclass
  class m6base98v #(type T = int);
    typedef int qk6_t;
    function void own(qk6_t x); endfunction
  endclass
  class z6der98v extends m6base98v#(int);
    function void bare(qk6_t x); endfunction
    function void qual(m6base98v#(int)::qk6_t x); endfunction
    function void qual2(p6v::a6win98v::qk6_t x); endfunction
  endclass
endpackage
module top6v;
  import p6v::*;
  z6der98v z;
  initial z = new();
endmodule
