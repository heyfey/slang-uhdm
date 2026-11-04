// § randSeqListRule401v
class C;
  int x, y;
  function void f();
    randsequence(go) go : { x = 1; }; endsequence
    y = 2;
  endfunction
endclass
module top;
  C c;
  initial begin c = new; c.f(); end
endmodule
