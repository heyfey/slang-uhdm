// § sysCallTimeKwNameSpan270
module top;
  realtime r1;
  real r2;
  initial begin
    r1 = $realtime();
    r2 = $realtime;
  end
endmodule
