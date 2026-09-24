// § elabCloneInstTreeUnstored144
module m(input logic a, b, c, clk1);
  default clocking @(negedge clk1); endclocking
  property p_triggers(start_event, end_event, form, clk = $inferred_clock);
    @clk (start_event ##0 end_event[->1]) |=> form;
  endproperty
  a1: assert property (p_triggers(a, b, c));
endmodule
