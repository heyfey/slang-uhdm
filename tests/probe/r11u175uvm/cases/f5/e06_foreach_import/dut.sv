package p1;
  class base;
    extern function void scan();
    int q[string];
  endclass
  function void base::scan();
    foreach (q[i]) begin
      q[i] = 1;
    end
  endfunction
endpackage
package p2;
  import p1::*;
  int k;
endpackage
module top;
  import p2::*;
  initial k = 1;
endmodule
