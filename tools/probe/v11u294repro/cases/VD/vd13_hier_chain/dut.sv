// § dottedCallHpSpansInvocation294
// a hierarchical call whose result is a class handle, chained, and a task call without parentheses
class cl; int v = 3; function int val(); return v; endfunction endclass
module sub;
  cl h = new();
  function cl get(); return h; endfunction
  task t; endtask
endmodule
module top(output int o);
  sub i0 ();
  initial begin o = i0.get().val(); i0.t; end
endmodule
