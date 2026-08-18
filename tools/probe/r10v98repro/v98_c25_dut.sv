// v98_c25 — is a GENERATE-BLOCK typedef inside a module in Surelog's
// module TypeDefMap (i.e. a candidate first writer)?
package p25v;
  class a25win98v;  typedef bit [7:0] wk25_t; endclass
  class m25base98v; typedef int wk25_t; endclass
  class z25der98v extends m25base98v;
    function void hot(wk25_t x); endfunction
  endclass
endpackage
module amod25v;
  if (1) begin : gblk25
    typedef byte wk25_t;
    wk25_t s;
  end
endmodule
module top25v;
  amod25v u();
  p25v::z25der98v z;
  initial z = new();
endmodule
