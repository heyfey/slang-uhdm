// § castRhsClonePerInst176
module submodule(input logic [3:0] w);
   wire [3:0] n, m;
   assign {n, m} = 8'(w);
endmodule
module top();
   logic [3:0] w;
   submodule u1(w);
   submodule u2(w);
endmodule
