package p1;
  class base #(type T = int);
    extern function void put(T t, int n = 2);
  endclass
  function void base::put(T t, int n = 2);
  endfunction
endpackage
module top;
  import p1::*;
  base #(int) b;
  initial begin b = new; b.put(1); end
endmodule
