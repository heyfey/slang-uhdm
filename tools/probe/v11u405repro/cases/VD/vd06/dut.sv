// § disableTargetScopeChain405
module top ();
  reg a = 0;
  initial begin
    fork
      begin : w
        #10 a = 1;
      end
      begin
        #3 disable w;
      end
    join
  end
endmodule
