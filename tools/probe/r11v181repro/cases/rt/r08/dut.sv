// § rootPathFullNameByChain181 (v11u181 break: select-free $root target inside a concatenation lvalue)
module top;
  logic [3:0] v;
  logic b;
  initial {$root.top.v, b} = 5'b01;
endmodule
