// § disableTargetScopeChain405
module top ();
  reg a = 0;
  initial begin
    begin : b2
      #10 a = 1;
    end
    disable b2;
  end
endmodule
