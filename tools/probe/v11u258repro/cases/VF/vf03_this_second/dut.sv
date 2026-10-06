// § forMultiInitAssign258 (a this. path as the SECOND initializer)
package p;
  class c;
    int i, j;
    function int f(); int n; for (i = 0, this.j = 0; i < 4; i++) n += j; return n; endfunction
  endclass
endpackage
module top; endmodule
