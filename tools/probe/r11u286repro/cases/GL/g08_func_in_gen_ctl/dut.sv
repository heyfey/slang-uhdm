// § genProcLvIdxCallSpan286 — control: a function declared in the generate block (currentSubSym already set) and a module-body process
module dut ();
  logic [7:0] w;
  logic [7:0] z;
  function automatic int fn(input int x); return x; endfunction
  for (genvar f = 0; f < 1; f++) begin : gf
    function automatic void g(); z[fn(2)] = 1'b1; endfunction
    always_comb g();
  end
  always_comb w[fn(3)] = 1'b1;
endmodule
