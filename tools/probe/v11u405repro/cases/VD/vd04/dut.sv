// § disableTargetScopeChain405
module top ();
  reg a = 0;
  task t;
    #2 a = 1;
    if (a) disable t;
    a = 0;
  endtask
  initial t;
endmodule
