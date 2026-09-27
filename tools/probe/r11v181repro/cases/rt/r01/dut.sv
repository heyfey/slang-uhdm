// § rootPathFullNameByChain181 (v11u181 break: $root lvalue with select inside a concatenation, an inc/dec, a nonblocking)
module top;
  logic [3:0] v;
  logic b;
  initial begin
    {$root.top.v[1], b} = 2'b01;
    $root.top.v[2]++;
    $root.top.v[3] <= 1'b1;
  end
endmodule
