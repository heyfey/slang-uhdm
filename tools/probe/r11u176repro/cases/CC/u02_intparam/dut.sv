// § castRhsClonePerInst176
module submodule();
   parameter int X = 20;
   assign a = int'(X);
endmodule
module top();
   submodule u_sub_default();
   submodule #(.X(5)) u_sub_5();
endmodule
