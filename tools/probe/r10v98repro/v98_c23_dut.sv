// v98_c23 — the same break with a PROGRAM as golden's first writer.
package p23v;
  class a23win98v;  typedef bit [7:0] wk23_t; endclass
  class m23base98v; typedef int wk23_t; endclass
  class z23der98v extends m23base98v;
    function void hot(wk23_t x); endfunction
  endclass
endpackage
program aprg23v;
  typedef int wk23_t;
  wk23_t q;
  initial q = 0;
endprogram
module top23v;
  p23v::z23der98v z;
  initial z = new();
endmodule
