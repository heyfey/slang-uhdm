// r10uvm123 arm D — a class declared inside a MODULE whose method casts a
// package vector typedef, and an INTERFACE subroutine doing the same.
`define DWID123 15
package dogwood123;
  typedef bit   [`DWID123-1:0] Petal_BT;
  typedef logic [`DWID123-1:0] petal_lt;
endpackage

interface dogwood123_if;
  import dogwood123::*;
  function automatic int ifn(int w);
    Petal_BT ib; petal_lt il;
    ib = Petal_BT'(w);
    il = petal_lt'(w);
    return 2;
  endfunction
endinterface

module dogwood123_dut;
  import dogwood123::*;
  class ModCls123;
    Petal_BT c_b;
    petal_lt c_l;
    function int mcast(int w);
      c_b = Petal_BT'(w);
      c_l = petal_lt'(w);
      return 6;
    endfunction
  endclass
  ModCls123 mc;
  initial mc = new();
endmodule
