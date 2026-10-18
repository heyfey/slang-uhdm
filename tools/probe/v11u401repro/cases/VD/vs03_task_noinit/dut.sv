// § loneVarDeclStmtDropped401
module top;
  task t();
    int v;
  endtask
  function int g();
    automatic int w = 7;
  endfunction
  initial t();
endmodule
