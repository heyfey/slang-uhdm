// § forMultiInitAssign258 (two initializers in a class method, the first a this. path (the base abstains as forInitSelectLhsBase254 does))
package p;
  class c;
    int i, j;
    function int f();
      int n;
      for (this.i = 0, j = 0; i < 4; i++) n += j;
      return n;
    endfunction
  endclass
endpackage
module top; endmodule
