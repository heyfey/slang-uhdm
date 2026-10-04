// § caOpArgIntFormalTs236 — an operation actual with a genvar in a for-generate continuous assignment (b11 alone)
module top (input int a, output int o3[2]);
  function automatic int f(int x);
    return x;
  endfunction
  for (genvar i = 0; i < 2; i++) begin : gl
    assign o3[i] = f(a + i);
  end
endmodule
