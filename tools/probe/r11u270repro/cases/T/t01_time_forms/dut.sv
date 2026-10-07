// § sysCallTimeKwNameSpan270
module top;
  time t1, t2;
  realtime r1;
  int x;
  initial begin
    t1 = $time();
    t2 = $time;
    r1 = $realtime();
    x = $random();
    x = $urandom();
    $display("%t", $time());
    t1 = $stime();
  end
endmodule
