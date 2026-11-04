// § disableTargetScopeChain405
module top ();
  reg a = 0;
  task t; #10 a = 1; endtask
  initial begin
    fork t; join_none
    #1 disable t;
  end
endmodule
