// v98_c20 — a typedef declared inside a class METHOD and inside a for/begin
// block: candidates the winner walk never visits.
package p20v;
  class a20win98v;
    function void mk();
      typedef bit [6:0] mk20_t;      // METHOD-local typedef
      mk20_t v; v = 0;
    endfunction
  endclass
  class m20base98v; typedef int mk20_t; function void own(mk20_t x); endfunction endclass
  class z20der98v extends m20base98v; function void hot(mk20_t x); endfunction endclass
endpackage
module top20v;
  import p20v::*;
  a20win98v a; z20der98v z;
  initial begin a = new(); z = new(); end
endmodule
