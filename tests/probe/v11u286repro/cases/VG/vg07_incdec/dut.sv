// § genProcLvIdxCallSpan286
module top;
  int v [4];
  function automatic int fn(int a); return a; endfunction
  for (genvar g = 0; g < 1; g++) begin : gl
    initial begin
      v[fn(g)]++;
      v[fn(1)] += 2;
    end
  end
endmodule
