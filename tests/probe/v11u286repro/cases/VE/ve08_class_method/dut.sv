// § escBlockNameSpanTrailSpace286
class C;
  int r;
  function void f();
    begin : \cb[1] 
      r = 3;
    end
  endfunction
endclass
module top;
  C c;
  initial begin c = new; c.f(); end
endmodule
