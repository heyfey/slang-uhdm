// t34a — MULTIPLICITY arm: the class lives in a MODULE whose own body carries
// the import.  Container = the module; the file has no $unit import.
package pk1;
  parameter int P1 = 7;
  typedef bit [3:0] nib_t;
  typedef struct { int a; } srec_t;
  int gv1;
  function automatic int f1(int x);
    return x + 1;
  endfunction
  task automatic t1(input int y);
  endtask
endpackage

module top;
  import pk1::*;
  class C;
    int m;
    function automatic int mc(int x);
      return x + 3;
    endfunction
  endclass
  C c;
  initial c = new();
endmodule
