// § forMultiInitAssign258 (a virtual-interface member as the first initializer in a class method)
interface bif; int v; endinterface
package p;
  class c;
    virtual bif vif; int i;
    function int f(); int n; for (vif.v = 0, i = 0; i < 3; i++) n++; return n; endfunction
  endclass
endpackage
module top; bif b(); endmodule
