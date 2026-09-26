// § hierPathSelIdxAtPath178
module top;
  function automatic int f(int x); return x; endfunction
  logic [7:0] a;
  logic [2:0] k;
  logic r;
  assign r = a[f(k)];
endmodule
