// § namedUnlinkedWrittenOrder207: decode only (residue) - a named call to a function declared LATER in the same interface or module lists the written order in golden although it is linked (Surelog compiled the caller before the callee had io_decls); ours takes the formal-slot list
interface ifc;
  int v;
  function automatic int first(int x);
    return later(.c(x), .a(1));
  endfunction
  function automatic int later(int a, int b = 3, int c = 4);
    return a + b + c;
  endfunction
  initial v = first(2);
endinterface
module top(output int o);
  ifc u();
  function automatic int f1(int x); return f2(.c(x), .a(1)); endfunction
  function automatic int f2(int a, int b = 3, int c = 4); return a * b + c; endfunction
  initial o = f1(5);
endmodule
