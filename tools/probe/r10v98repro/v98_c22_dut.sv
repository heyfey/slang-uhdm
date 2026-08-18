// v98_c22 — the same break with a NON-TOP MODULE as golden's first writer.
package p22v;
  class a22win98v;  typedef bit [7:0] wk22_t; endclass
  class m22base98v; typedef int wk22_t; endclass
  class z22der98v extends m22base98v;
    function void hot(wk22_t x); endfunction
  endclass
endpackage
module amod22v;
  typedef int wk22_t;
  wk22_t s;
endmodule
module top22v;
  amod22v u();
  p22v::z22der98v z;
  initial z = new();
endmodule
