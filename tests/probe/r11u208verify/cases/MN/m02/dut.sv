// § methodArgNestedRefChain201
interface ifc;
  function automatic int f(int k); return k; endfunction
endinterface
module m02 (input logic [7:0] p, output int y1, output int y2);
  ifc i();
  int a[4];
  logic [1:0] k;
  function automatic int g(int z); return z; endfunction
  always_comb y1 = i.f(a[k] + g(p[k]));
  assign y2 = i.f(i.f(p[3:0]) * 2);
endmodule
