// t34d — ORDER arm: does the class's OWN typedef sort into the imported ones
// by NAME (writeDataTypes walks a std::map keyed by the UNQUALIFIED name), or
// does it simply follow them?  `aaa_t` sorts FIRST, `zzz_t` LAST.
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
  import pk1::*;
  class C;
    typedef bit [1:0] zzz_t;
    typedef bit [2:0] aaa_t;
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
