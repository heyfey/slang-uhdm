// v131 arm D — the same shapes in other homes: package task, class task/function,
// program, and a module with 1..3 instances.
package Pdhome;
  int pkgv;
  task automatic freeTask();
    fork : ftNamed pkgv = 1; join_none : ftNamed
    fork pkgv = 2; join_any
    fork : ftEmpty join : ftEmpty
  endtask
  class Cdh;
    int cv;
    task automatic ctask();
      fork : ctNamed cv = 3; join_none : ctNamed
      fork begin cv = 4; end begin cv = 5; end join
      fork : ctEmpty join_none : ctEmpty
    endtask
    function int cfun();
      fork : cfNamed cv = 6; join_none : cfNamed
      return cv;
    endfunction
  endclass
endpackage

module Dleaf #(parameter int WHICH = 0);
  import Pdhome::*;
  int lv;
  initial begin
    fork : leafNamed lv = WHICH; join_none : leafNamed
    fork lv = WHICH + 1; join_any
    fork : leafEmpty join_any : leafEmpty
  end
endmodule

module Dtop;
  Dleaf #(.WHICH(1)) i1 ();
  Dleaf #(.WHICH(2)) i2 ();
  Dleaf #(.WHICH(3)) i3 ();
endmodule

program Pdprog;
  int pv;
  initial begin
    fork : progNamed pv = 7; join_none : progNamed
    fork pv = 8; join
    fork : progEmpty join_none : progEmpty
  end
endprogram
