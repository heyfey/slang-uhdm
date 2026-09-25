// § foreachArrPathVarForm157
class inner; int arr[4]; int q[$]; endclass
class outer; inner in1; function new(); in1 = new; endfunction
  function int f(); int s = 0; foreach (in1.arr[i]) s += in1.arr[i]; foreach (this.in1.q[j]) s += j; return s; endfunction
endclass
module top; outer o; initial begin o = new; void'(o.f()); end endmodule
