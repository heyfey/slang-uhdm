// § sysCallTimeKwNameSpan270
module top (input clk, output longint o, output real r);
  longint t0;
  initial t0 = $time();
  always @(posedge clk) begin
    o <= $time() - t0;
    r <= $realtime ( );
    $display("%t %t", $time(), $realtime());
    if ($time() > 10 && $time( ) < 100) o <= ($time() > 5) ? $time() : 0;
  end
endmodule
