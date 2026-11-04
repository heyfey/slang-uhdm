// § genProcLvIdxCallSpan286 — generate process in a child at instance depth 2
module leaf ();
  parameter int P = 2;
  logic [7:0] w;
  function automatic int fn(input int x); return x; endfunction
  for (genvar f = 0; f < 2; f++) begin : gf
    always_comb w[fn(P)] = 1'b1;
  end
endmodule
module mid (); leaf l (); endmodule
module dut (); mid m (); endmodule
