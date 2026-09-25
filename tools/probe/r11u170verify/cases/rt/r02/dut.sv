// § rootPathOwnNames157
module top; logic [7:0] v; int i; sub u(); endmodule
module sub;
  logic [1:0] a; logic b;
  initial begin
    b = $root.top.v[$root.top.i];
    a = $root.top.v[$root.top.i +: 2];
  end
endmodule
