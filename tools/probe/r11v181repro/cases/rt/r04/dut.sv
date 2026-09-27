// § rootPathFullNameByChain181 (v11u181 break: $root inside a function body, a for loop, a while condition and a return)
module top;
  logic [7:0] v;
  int n;
  function automatic int f(int k);
    for (int i = 0; i < $root.top.n; i++) k += $root.top.v;
    while ($root.top.n > k) k++;
    return $root.top.v + k;
  endfunction
  initial n = f(2);
endmodule
