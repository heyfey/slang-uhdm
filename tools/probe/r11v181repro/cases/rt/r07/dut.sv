// § rootPathFullNameByChain181 § rootNetPathOwnNames181 (v11u181 break: select-free $root inc/dec operands, a compound assignment)
module top;
  logic [3:0] w;
  int n;
  initial begin
    $root.top.w++;
    --$root.top.n;
    $root.top.n += 2;
  end
endmodule
