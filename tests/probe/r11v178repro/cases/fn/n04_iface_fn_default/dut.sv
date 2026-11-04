// § refFullNameThroughNamedExpr175
interface ifc;
  localparam int W = 2;
  int sig;
  function automatic int f(int a = W); return a + sig; endfunction
  task automatic t(int k); sig = k; endtask
endinterface
module top;
  ifc i();
  int r;
  task automatic run(int k); i.t(k); r = i.f(k); endtask
  initial run(3);
endmodule
