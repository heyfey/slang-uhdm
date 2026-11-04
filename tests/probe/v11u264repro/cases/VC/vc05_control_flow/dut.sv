// § ctorBidLhsCloneCopy264
package bp;
  class c;
    int r;
    extern function new(int k);
  endclass
  function c::new(int k);
    int i;
    logic [7:0] m;
    for (i = 0; i < k; i++) begin
      m = i;
      r += m;
    end
    if (k > 2) begin
      int inner;
      inner = k;
      r = inner;
    end
  endfunction
endpackage
package up;
  import bp::*;
  class d extends c;
    function new(); super.new(3); endfunction
  endclass
endpackage
module top;
  import up::*;
  initial begin d o = new(); end
endmodule
