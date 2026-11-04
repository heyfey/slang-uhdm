package p1;
  class base;
    extern function bit [3:0] f(bit [7:0] v, logic [1:0] w, int q[$]);
  endclass
  function bit [3:0] base::f(bit [7:0] v, logic [1:0] w, int q[$]);
    return v[3:0];
  endfunction
endpackage
module top;
  import p1::*;
  base b;
  int qq[$];
  initial begin b = new; void'(b.f(8'h1, 2'b1, qq)); end
endmodule
