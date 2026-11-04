// § genProcLvIdxCallSpan286 — named-argument call, nested call argument and a genvar argument as lvalue indices in a generate process
module dut ();
  parameter int P = 1;
  logic [7:0] w;
  logic [7:0] z [4];
  function automatic int fn(input int x); return x; endfunction
  function automatic int gn(input int a, input int b); return a + b; endfunction
  for (genvar f = 0; f < 2; f++) begin : gf
    always_comb begin
      w[fn(.x(P))] = 1'b1;
      z[gn(f, fn(P))][f] = 1'b0;
    end
  end
endmodule
