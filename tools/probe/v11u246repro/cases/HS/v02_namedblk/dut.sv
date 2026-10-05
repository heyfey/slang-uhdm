// § hpFnStaticTrailScopeJoin246
package p;
  class c;
    function void f();
      begin : blk
        static int x;
        x = 1;
      end
    endfunction
    function int g();
      return f.blk.x;
    endfunction
  endclass
endpackage
module top;
endmodule
