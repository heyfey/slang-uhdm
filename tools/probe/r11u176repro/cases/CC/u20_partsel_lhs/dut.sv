// § castRhsClonePerInst176
module submodule(input logic [3:0] w);
   wire [15:0] n;
   assign n[7:0] = 8'(w);
endmodule
module top();
   logic [3:0] w;
   submodule u1(w);
   submodule u2(w);
endmodule
