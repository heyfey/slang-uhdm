// § disableTargetScopeChain405
module top ();
  reg a = 0;
  initial begin : b1
    #10 a = 1;
  end
  initial begin
    #5 disable top.b1;
  end
endmodule
