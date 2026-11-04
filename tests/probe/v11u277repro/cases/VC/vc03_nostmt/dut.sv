// § ctorRetVarSiblingSpan277
package p;
  class f1;
    int y;
    function new();
      y = 1;
    endfunction
  endclass
  class f2;
    int y;
    function new;
      int z;
      z = 2;
      y = z;
    endfunction
  endclass
  class f3 extends f1;
    function new();
      super.new();
    endfunction
  endclass
endpackage
module top;
  p::f2 x;
endmodule
