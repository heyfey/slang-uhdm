// § genProcLvIdxCallSpan286 — associative-array key lvalue (blocking) in a generate process
module dut ();
  int aa [int];
  function automatic int fn(input int x); return x; endfunction
  for (genvar f = 0; f < 1; f++) begin : gf
    always_comb aa[fn(5)] = 1;
  end
endmodule
