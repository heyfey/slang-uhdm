// § sysCallTimeKwNameSpan270
module top (input clk, output time t, output realtime rt);
  time t0;
  initial t0 = $time();
  always @(posedge clk) begin
    t <= $time() - t0;
    rt <= $realtime ( );
    $display("%t %t", $time(), $realtime());
  end
  wire [63:0] w = $time();
endmodule
