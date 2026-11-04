// § classMethodQualSpan144
class B #(int N = 1);
  virtual function automatic int f(int a);
    return a + N;
  endfunction
  protected function new();
  endfunction
  local task
     t2();
  endtask
endclass
class D extends B #(2);
  virtual function automatic int f(int a);
    return a;
  endfunction
  function new(); super.new(); endfunction
endclass
module top; endmodule
