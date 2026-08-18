// v98_c26 — is a FUNCTION-LOCAL typedef inside a module a candidate first
// writer?  And a typedef inside a module-nested CLASS must stay group 4.
package p26v;
  class a26win98v;  typedef bit [7:0] wk26_t; endclass
  class m26base98v; typedef int wk26_t; endclass
  class z26der98v extends m26base98v;
    function void hot(wk26_t x); endfunction
  endclass
endpackage
module amod26v;
  function int f26();
    typedef byte wk26_t;
    wk26_t v; v = 0; return v;
  endfunction
  int r;
  initial r = f26();
endmodule
module top26v;
  amod26v u();
  p26v::z26der98v z;
  initial z = new();
endmodule
