// § castRhsClonePerInst176
module submodule(input logic [3:0] w);
   assign a = int'(w);
endmodule
module top();
   logic [3:0] w;
   submodule u1(w);
   submodule u2(w);
endmodule
