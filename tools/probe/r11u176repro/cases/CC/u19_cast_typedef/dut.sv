// § castRhsClonePerInst176
module submodule(input logic [3:0] w);
   typedef logic [7:0] b_t;
   assign a = b_t'(w);
endmodule
module top();
   logic [3:0] w;
   submodule u1(w);
   submodule u2(w);
endmodule
