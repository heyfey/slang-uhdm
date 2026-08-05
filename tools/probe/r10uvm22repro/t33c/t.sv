// t33c — arm C: the import is at $unit scope and the class is declared at
// $unit scope too (the Scoreboard / SimpleUVM shape).  Does a design class
// whose CONTAINER is the compilation unit inherit the imported listings?
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

class C;
  int m;
  function automatic int mc(int x);
    return x + 3;
  endfunction
endclass

module top;
  C c;
  initial c = new();
endmodule
