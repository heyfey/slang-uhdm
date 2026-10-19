// § disableTargetScopeChain405
module top ();
  reg a = 0;
  task t1; #10 a = 1; endtask
  task t2; #5 disable t1; endtask
  initial fork t1; t2; join
endmodule
