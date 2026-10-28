// § vsTrailRangeColonJoin453
module top;
  for (genvar g = 0; g < 2; g++) begin : gb
    function automatic void f(int i0);
      logic [3:0][7:0] m;
      m[i0][i0+:2] = 1;
    endfunction
  end
endmodule
