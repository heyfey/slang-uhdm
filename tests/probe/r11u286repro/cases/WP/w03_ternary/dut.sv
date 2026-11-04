// § withCallParenSyntax286 — ternary branches and a $display argument
package p;
  class c;
    int q[$];
    function void f();
      int r;
      r = (r > 0) ? (q.sum() with ( item )) : 0;
      r = (r > 0) ? 0 : (q.product() with ( item ));
      $display("%0d", (q.sum() with ( item )));
    endfunction
  endclass
endpackage
module top; import p::*; endmodule
