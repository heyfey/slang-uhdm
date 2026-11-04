// § clsBodyCallBindsHomeTopTf446
package p;
  function automatic int rep(int v);
    return v + 1;
  endfunction
endpackage
package q;
  import p::*;
  class C #(int W = 2);
    function int f(int a);
      return rep(a) + W;
    endfunction
  endclass
  typedef C #(3) c3_t;
endpackage
module top;
  import q::*;
  c3_t c;
  initial begin
    c = new;
    $display(c.f(1));
  end
endmodule
