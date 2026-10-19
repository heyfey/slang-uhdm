// § disableTargetScopeChain405
module top ();
  reg a = 0;
  initial begin: outer
    #10 a = 1;
    disable outer;
  end
endmodule
