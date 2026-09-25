// § ppFileCallArgBody168
`define CALLGET(o, r) \
  begin \
    r = o.get(); \
  end
class C;
  int x;
  function int get(); return x; endfunction
  function void run();
    int r;
    `CALLGET(this, r)
  endfunction
endclass
module top;
  initial begin
    C c = new;
    c.run();
  end
endmodule
