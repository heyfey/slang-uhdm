// v98_c27 — a typedef inside an UNCONDITIONAL `generate ... endgenerate`
// region of a module: candidate first writer or not?
package p27v;
  class a27win98v;  typedef bit [7:0] wk27_t; endclass
  class m27base98v; typedef int wk27_t; endclass
  class z27der98v extends m27base98v;
    function void hot(wk27_t x); endfunction
  endclass
endpackage
module amod27v;
  generate
    typedef byte wk27_t;
    wk27_t s;
  endgenerate
endmodule
module top27v;
  amod27v u();
  p27v::z27der98v z;
  initial z = new();
endmodule
