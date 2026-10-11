// § genProcLvIdxCallSpan286
module top #(parameter P = 2);
  logic [7:0] v;
  function automatic int fn(int a); return a; endfunction
  for (genvar g = 0; g < 2; g++) begin : gl
    always_comb v[fn(P + g)] = 1'b1;
  end
endmodule
