// § forMultiInitAssign258 (two initializers in a class method)
package p;
  class c;
    int i, j;
    function int f();
      int n;
      for (i = 0, j = 0; i < 4; i++) n += j;
      return n;
    endfunction
  endclass
endpackage
module top; endmodule
