// § foreachArrPathVarForm157
class inner; int m[2][3]; endclass
class outer;
  inner in1;
  function new(); in1 = new; endfunction
  function int f(); int s = 0; foreach (in1.m[i, j]) s += in1.m[i][j] + i + j; return s; endfunction
endclass
module top; outer o; initial begin o = new; void'(o.f()); end endmodule
