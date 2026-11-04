// § emptyConcatArrayVar413
module top;
  byte q[$];
  function automatic void clr();
    q = {};
  endfunction
  initial clr();
endmodule
