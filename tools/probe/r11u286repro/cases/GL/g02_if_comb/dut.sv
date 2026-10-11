// § genProcLvIdxCallSpan286 — if-generate always_comb, one-level select
module dut ();
  parameter int P = 3;
  logic [63:0] v [4];
  logic [7:0] w;
  function automatic int fn(input int x); return x; endfunction
  if (P > 1) begin : gi
    always_comb begin
      v[fn(P)] = 0;
      w[fn(1)] = 1'b1;
    end
  end
endmodule
