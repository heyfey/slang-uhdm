// § loneVarDeclStmtDropped401
module top;
  function void f();
    int v = 5;
  endfunction
  initial f();
endmodule
