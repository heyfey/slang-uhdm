// § castRhsClonePerInst176
module submodule(input logic [3:0] w);
   wire [15:0] n;
   assign n[0] = 1'(w);
endmodule
module top();
   logic [3:0] w;
   submodule u1(w);
   submodule u2(w);
endmodule
