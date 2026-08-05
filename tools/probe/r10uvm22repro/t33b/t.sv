// t33b — arm B: the SAME two packages, but pk2 does NOT import pk1 (it
// qualifies the one name it needs).  The control for t33a.
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

package pk2;
  parameter int P2 = 9;
  typedef bit [7:0] byt_t;
  int gv2;
  function automatic int f2(int x);
    return x + 2;
  endfunction
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
