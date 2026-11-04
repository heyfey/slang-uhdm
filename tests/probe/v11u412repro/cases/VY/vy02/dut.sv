// § modNettypeTypedef412
module top;
  function automatic real rsum(input real d []);
    rsum = 0.0;
    foreach (d[i]) rsum += d[i];
  endfunction
  nettype real rnet with rsum;
endmodule
module other;
  function automatic real rsum(input real d []);
    rsum = 1.0;
  endfunction
endmodule
