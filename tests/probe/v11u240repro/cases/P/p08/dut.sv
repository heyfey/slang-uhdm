// § hoistPoolSourceOrder240: the constant slots in out-of-body bodies (part-select bound, indexed width, replication, dimension)
package hp;
  class zk;
    int idx, w;
    logic [31:0] v;
    extern function logic [7:0] f();
  endclass
  function logic [7:0] zk::f();
    logic [7:0] r;
    r = v[idx +: 8];
    r = {4{v[idx]}} ^ r;
    return r;
  endfunction
  class ak;
    int idx;
    logic [31:0] v;
    extern function bit g();
  endclass
  function bit ak::g();
    return v[idx];
  endfunction
endpackage
module top;
  import hp::*;
  initial $display("x");
endmodule
