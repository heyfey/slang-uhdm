// § genProcLvIdxCallSpan286 — call inside an operation index, compound and inc/dec lvalues
module dut ();
  parameter int P = 1;
  logic [7:0] w;
  int c [4];
  function automatic int fn(input int x); return x; endfunction
  for (genvar f = 0; f < 1; f++) begin : gf
    always_comb begin
      w[fn(P) + 1] = 1'b1;
      c[fn(P)] += 2;
      c[fn(0)]++;
    end
  end
endmodule
