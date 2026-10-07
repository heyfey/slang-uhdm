// § sysCallTimeKwNameSpan270
module top (input logic [3:0] a, output int o, output time t);
  always_comb begin
    o = $signed(a) + $unsigned(a);
    t = $time + $realtime;
  end
endmodule
