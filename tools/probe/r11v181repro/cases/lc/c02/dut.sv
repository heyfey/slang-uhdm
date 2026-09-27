// § procLvPartSelBoundCallName181v § procLvIdxCallWholeSpan181 (v11u181 break, fixed: call indices in a concatenation lvalue, an output argument, a cont assign control, part-select bounds inside a concatenation)
module top;
  logic [7:0] a, b;
  wire [7:0] w;
  function automatic int f(int x); return x; endfunction
  task automatic t(output logic o); o = 1'b1; endtask
  assign w[f(2)] = 1'b1;
  initial begin
    {a[f(1)], b[f(2)]} = 2'b10;
    t(a[f(3)]);
    {a[f(5):f(4)], b[f(6)-:2]} = 4'h5;
  end
endmodule
