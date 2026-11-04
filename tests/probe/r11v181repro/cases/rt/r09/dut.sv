// § rootPathFullNameByChain181 § rootPathElemOwnName181 (v11u181 break: $root in a module-local class method and a module task with a local)
module top;
  int n;
  class C;
    int k;
    function void f();
      k = $root.top.n + 1;
    endfunction
  endclass
  task automatic t();
    int loc;
    loc = $root.top.n;
    $display(loc);
  endtask
  initial begin C c = new; c.f(); t(); end
endmodule
