// § sysCallTimeKwNameSpan270
module top (input clk, output logic o);
  time a;
  always @(posedge clk) begin
    a = ($time() > 10) ? $time() : 0;
    o = {$time()} != 0;
    a = $time()/2 + $time;
    a = $stime();
  end
endmodule
