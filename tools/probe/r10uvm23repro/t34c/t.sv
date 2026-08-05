// t34c — MULTIPLICITY arm: the class lives in a PACKAGE and the import is at
// $unit scope in the same file.  Predicts x4 (file x2 + the package's own
// objects, filled x2 by its local-file loop).
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

import pk1::*;

package pk2;
  class C;
    int m;
    function automatic int mc(int x);
      return x + 3;
    endfunction
  endclass
endpackage

module top;
  pk2::C c;
  initial c = new();
endmodule
