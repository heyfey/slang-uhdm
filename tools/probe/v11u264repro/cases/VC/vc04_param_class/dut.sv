// § ctorBidLhsCloneCopy264
package bp;
  class pc #(type T = int, int N = 2);
    T q;
    extern function new(T init);
  endclass
  function pc::new(T init);
    T tmp;
    int cnt;
    tmp = init;
    cnt = N;
    q = tmp;
  endfunction
endpackage
package up;
  import bp::*;
  class u extends pc #(byte, 3);
    function new(); super.new(8'd1); endfunction
  endclass
endpackage
module top;
  import up::*;
  initial begin u o = new(); end
endmodule
