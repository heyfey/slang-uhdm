// § disableTargetScopeChain405
module top ();
  reg a = 0;
  initial begin
    fork: blk
      #10 a = 1;
    join_none
    disable blk;
  end
endmodule
