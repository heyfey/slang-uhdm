// § loneVarDeclStmtDropped401
class R; endclass
class C;
  function void f();
    R r = new;
  endfunction
  task t();
    int k = 3;
  endtask
endclass
module top;
  C c;
  initial begin c = new; c.f(); end
endmodule
