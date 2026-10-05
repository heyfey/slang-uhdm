// § cloneForIncBindsHomeVar238
package p;
  class base #(type T = int);
    T items[$];
    extern function int count(T v);
  endclass
  function int base::count(T v);
    for (int i = 0; i < items.size(); i++)
      if (items[i] == v) count++;
  endfunction
  class leaf extends base #(byte);
    function int c2();
      for (int k = 0; k < 2; ++k) c2 += k;
    endfunction
  endclass
endpackage
import p::*;
module top;
  leaf l;
  int r;
  initial begin l = new; r = l.count(1) + l.c2(); end
endmodule
