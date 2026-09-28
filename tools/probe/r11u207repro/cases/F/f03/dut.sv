// § namedSlotFillerRootFile207: a resolved task and function with named fillers in a module, an interface and a class
interface ifc;
  function automatic int fi(int a, int b = 5); return a + b; endfunction
  int v;
  initial v = fi(.a(2));
endinterface
module top(input int i, output int o);
  task automatic tk(input int a, input int b = 2, output int c); c = a + b; endtask
  function automatic int f(int a, int b = 1, int c = 2); return a + b + c; endfunction
  ifc u();
  initial begin int c; tk(.a(i), .c(c)); end
  always_comb o = f(.a(i), .c(1));
endmodule
