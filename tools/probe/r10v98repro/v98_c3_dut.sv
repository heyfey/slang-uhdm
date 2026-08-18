// v98_c3 — H7: does a MODULE / PROGRAM / INTERFACE level typedef of the racing
// name beat the classes?  The patch's winner table only walks TOP instances.
package p3v;
  class mid3v;
    typedef int rk3_t;
    function void own(rk3_t x); endfunction
  endclass
  class zder3v extends mid3v;
    function void hot(rk3_t x); endfunction
  endclass
endpackage
module sub3v;                 // NOT a top instance
  typedef bit [3:0] rk3_t;
  rk3_t s;
endmodule
program prog3v;
  typedef bit [7:0] rk3_t;
  rk3_t q;
  initial q = 0;
endprogram
interface if3v;
  typedef bit [11:0] rk3_t;
  rk3_t w;
endinterface
module top3v;
  import p3v::*;
  sub3v u_sub();
  zder3v z;
  initial z = new();
endmodule
