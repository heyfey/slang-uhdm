// t34e — DUP-NAME / SHARE arm: pk1 and the class both declare `f1`, and pk1
// and pk2 both export a `nib_t`.  Predicts: the class's task_func listing keeps
// pk1's `f1` and DROPS its own (the :311 duplicate-name check runs before the
// class's own members are compiled), while the class's own `m` variable still
// lands after pk1's `gv1` (no such check on the variable loop).  A second
// import of pk3 exercises two import items in order.
package pk1;
  parameter int P1 = 7;
  typedef bit [3:0] nib_t;
  int gv1;
  function automatic int f1(int x);
    return x + 1;
  endfunction
endpackage

package pk3;
  parameter int P3 = 3;
  typedef bit [5:0] mmm_t;
  int gv3;
  function automatic int f3(int x);
    return x + 3;
  endfunction
endpackage

package pk2;
  import pk1::*;
  import pk3::*;
  class C;
    int m;
    function automatic int f1(int x);
      return x + 99;
    endfunction
  endclass
endpackage

module top;
  pk2::C c;
  initial c = new();
endmodule
