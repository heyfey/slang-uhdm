// § ppFileCallArgBody168
`include "mac.svh"
class C;
  int x;
  function void put(int a); x = a; endfunction
endclass
module top;
  C c;
  initial begin
    c = new;
    `DOIT(c, 3)
  end
endmodule
