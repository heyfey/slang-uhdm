// § rootPathFullNameByChain181 (v11u181 break: select-free $root lvalue in a concatenation, inc/dec, force/release)
module top;
  logic [3:0] v;
  logic [3:0] w;
  logic b;
  initial begin
    {$root.top.v, b} = 5'b01;
    $root.top.w++;
    force $root.top.v = 4'd3;
    release $root.top.v;
  end
endmodule
