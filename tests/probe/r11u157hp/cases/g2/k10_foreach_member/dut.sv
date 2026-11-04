class inner; int v; int arr[4]; function int get(); return v; endfunction endclass
class outer;
  int x; int q[$]; inner in1; byte bytes[];
  function void f(); foreach (in1.arr[j]) x = j; endfunction
endclass
module top; outer o; initial begin o = new; end endmodule
