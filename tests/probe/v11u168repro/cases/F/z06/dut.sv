// § ppFileCallArgBody168
`include "mac.svh"
class C;
  int x;
  function int get(); return x; endfunction
  function void run();
    int r;
    `G1(this, r)
  endfunction
endclass
module top;
  initial begin
    C c = new;
    c.run();
  end
endmodule
