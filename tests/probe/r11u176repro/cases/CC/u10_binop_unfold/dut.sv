// § castRhsClonePerInst176
module submodule(input logic w);
   assign d = w & 1'b1;
endmodule
module top();
   logic w;
   submodule u1(w);
   submodule u2(w);
endmodule
