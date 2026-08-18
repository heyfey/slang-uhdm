// v98_c24 — group ORDER measurement: is a PROGRAM-level typedef in the same
// sorted group as the modules/interfaces, or in a LATER group?  `aprg24v`
// sorts before `zmod24v`; if golden picks zmod24v's, programs are group 3.
package p24v;
  class a24win98v;  typedef bit [7:0] wk24_t; endclass
  class m24base98v; typedef int wk24_t; endclass
  class z24der98v extends m24base98v;
    function void hot(wk24_t x); endfunction
  endclass
endpackage
program aprg24v;
  typedef shortint wk24_t;
  wk24_t q;
  initial q = 0;
endprogram
module zmod24v;
  typedef byte wk24_t;
  wk24_t s;
endmodule
module top24v;
  zmod24v u();
  p24v::z24der98v z;
  initial z = new();
endmodule
