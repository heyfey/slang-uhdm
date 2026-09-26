// § castRhsClonePerInst176
module submodule(input logic [3:0] w);
   logic [31:0] v;
   assign v = int'(w);
endmodule
module top();
   logic [3:0] w;
   submodule u1(w);
   submodule u2(w);
endmodule
