// § genProcLvIdxCallSpan286 — interface body generate process with a call index
interface ifc;
  logic [7:0] w;
  function automatic int fn(input int x); return x; endfunction
  for (genvar f = 0; f < 1; f++) begin : gf
    always_comb w[fn(f)] = 1'b1;
  end
endinterface
module dut ();
  ifc u ();
endmodule
