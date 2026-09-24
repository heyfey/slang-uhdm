// r10uvm101 discovery grid: nonblocking trigger timing controls.
module n101;
  event ev;
  event clk_ev;
  int d = 2;
  initial begin
    ->> ev;
    ->> #1 ev;
    ->> #d ev;
    ->> #(d) ev;
    ->> #(d + 1) ev;
    ->> @(clk_ev) ev;
    ->> repeat (2) @(clk_ev) ev;
  end
endmodule
