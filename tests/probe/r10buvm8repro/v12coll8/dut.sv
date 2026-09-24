// COLLISION, second layer: 3-way, and a SELECT / CAST / OPERATION whose BASE
// name collides with an earlier callee formal.
package dp12;
  import "DPI-C" context function int dpi12(input int a, input int b, input int c);
  function int h3 (int a, int b, int c); return dpi12(a, b, c); endfunction
  function int h2 (int a, int b);        return dpi12(a, b, 0); endfunction
  function int d_aaa (int a);            return h3(a, a, a); endfunction
  function int d_sel (logic [7:0] a);    return h2(int'(a), int'(a[0])); endfunction
  function int d_op  (int a);            return h2(a, a + 1); endfunction
  function int d_op0 (int a);            return h2(a + 1, a); endfunction
endpackage
module m12;
  int r[4]; logic [7:0] vv;
  initial begin
    r[0]=dp12::d_aaa(1); r[1]=dp12::d_sel(vv); r[2]=dp12::d_op(1); r[3]=dp12::d_op0(1);
  end
endmodule
