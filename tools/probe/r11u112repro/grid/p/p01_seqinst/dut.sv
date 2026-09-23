module m(logic a, b, c, clk1, clk2);
  default clocking @(negedge clk1); endclocking
  logic rst1;
  default disable iff rst1;
  property p_triggers(start_event, end_event, form, clk = $inferred_clock,
                      rst = $inferred_disable);
    @clk disable iff (rst) (start_event ##0 end_event[->1]) |=> form;
  endproperty
  a1: assert property (p_triggers(a, b, c));
endmodule
