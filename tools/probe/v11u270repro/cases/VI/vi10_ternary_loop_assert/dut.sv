// § insideSetParamFoldKeepsPa270
module top #(parameter int P = 2) (input clk, input int w, output int o);
  localparam int Q = 5;
  function automatic int f(int x);
    int r = 0;
    for (int i = 0; i inside {P, Q}; i++) r += (x inside {P} ? 1 : 0);
    return r;
  endfunction
  always_ff @(posedge clk) o <= f(w);
  a1: assert property (@(posedge clk) w inside {P, Q} |-> o != 0);
  always_comb begin
    if (w inside {Q}) $display("q");
  end
endmodule
