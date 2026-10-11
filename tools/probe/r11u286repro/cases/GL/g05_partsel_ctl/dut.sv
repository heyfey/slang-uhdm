// § genProcLvIdxCallSpan286 — constant slots: part-select bounds (name span kept) and indexed part-select base and width
module dut ();
  logic [15:0] a;
  logic [15:0] b;
  function automatic int fn(input int x); return x; endfunction
  for (genvar f = 0; f < 1; f++) begin : gf
    always_comb begin
      a[fn(3):fn(0)] = 4'h1;
      b[fn(4) +: 4] = 4'h2;
      b[fn(8) -: 2] = 2'h1;
    end
  end
endmodule
