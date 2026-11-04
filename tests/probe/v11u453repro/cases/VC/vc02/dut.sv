// § vsTrailRangeColonJoin453
function automatic void f(int i0);
  logic [3:0][7:0] m;
  m[1][3:2] = 1;
endfunction
module top;
  initial f(1);
endmodule
