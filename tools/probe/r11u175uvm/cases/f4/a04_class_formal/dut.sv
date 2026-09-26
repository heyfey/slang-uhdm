package p1;
  class item; endclass
  class base;
    extern function item get(item it, input item other = null);
  endclass
  function item base::get(item it, input item other = null);
    return it;
  endfunction
endpackage
module top;
  import p1::*;
  base b;
  initial begin b = new; void'(b.get(null)); end
endmodule
