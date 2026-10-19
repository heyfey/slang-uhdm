// § disableTargetScopeChain405
module top ();
  reg a = 0;
  initial begin : outer
    fork
      begin #5 disable outer; end
      begin #10 a = 1; end
    join
  end
endmodule
