// § caOpArgIntFormalTs236 — operation actuals of int formals in processes and in a function body
module top (input int a, input logic [7:0] v, output int o, output int o2, output int o3);
  function automatic int h(int x, int k);
    return x + k;
  endfunction
  function automatic int w(int z);
    int l;
    l = z * 2;
    return h(l + 1, z - 1);
  endfunction
  always_comb o = h(a, a + 1);
  always_comb begin
    int t;
    t = a;
    o2 = h(t, t << 1);
  end
  assign o3 = w(a);
endmodule
