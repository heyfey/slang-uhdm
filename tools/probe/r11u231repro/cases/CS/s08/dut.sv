// § tfArgClassSpecNameSpan231 — a $unit class and a program function
class proxy #(type S=int);
  S v;
endclass
class adapter;
  function void f(proxy#(int) px);
  endfunction
endclass
program pr;
  function automatic void pf(proxy#(byte) a);
  endfunction
endprogram
module top;
endmodule
