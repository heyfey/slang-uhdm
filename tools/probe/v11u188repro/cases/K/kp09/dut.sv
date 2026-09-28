// § classTpKeywordTsAtDefault188
package p;
  class c #(type T = logic);
    T p;
    task automatic t1(ref T x);
      x = p;
    endtask
    function void f1(input T a);
      p = a;
    endfunction
    task automatic t2(output T o, inout T io);
      o = io;
    endtask
  endclass
endpackage
module top; endmodule
