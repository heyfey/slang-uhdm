// § disableTargetScopeChain405
module top ();
  reg a = 0;
  task t; #5 a = 1; endtask
  initial begin
    fork t(); join_none
    disable t;
  end
endmodule
