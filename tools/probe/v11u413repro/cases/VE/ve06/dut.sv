// § emptyConcatArrayVar413
class C;
  int q[$];
  function void clr();
    q = {};
  endfunction
endclass
module top;
  C c;
  initial begin c = new; c.clr(); end
endmodule
