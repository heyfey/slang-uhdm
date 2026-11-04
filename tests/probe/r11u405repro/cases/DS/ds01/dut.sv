// § disableTargetScopeChain405
module top ();
  reg a = 0;
  initial fork
    begin: block
      #10 a = 1;
    end
    #15 disable block;
  join
endmodule
