// § ppFileCallArgBody168
`include "mac.svh"
class C;
  function string name(); return "c"; endfunction
  function void run();
    `OUTER(this)
  endfunction
endclass
module top;
  initial begin
    C c = new;
    c.run();
  end
endmodule
