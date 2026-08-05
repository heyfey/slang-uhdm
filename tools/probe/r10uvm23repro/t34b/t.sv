// t34b — MULTIPLICITY arm: the class lives in a MODULE and the import is at
// $unit scope in the SAME FILE.  The class sees the file's items (x2, because
// CompileFileContent adds each one twice) PLUS the module's own objects, which
// the module's own local-file loop filled with the same two.  Predicts x4.
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

module top;
  class C;
    int m;
    function automatic int mc(int x);
      return x + 3;
    endfunction
  endclass
  C c;
  initial c = new();
endmodule
