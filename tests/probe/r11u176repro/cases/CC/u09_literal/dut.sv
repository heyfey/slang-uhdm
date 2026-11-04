// § castRhsClonePerInst176
module submodule();
   assign a = int'(5);
endmodule
module top();
   submodule u1();
   submodule u2();
endmodule
