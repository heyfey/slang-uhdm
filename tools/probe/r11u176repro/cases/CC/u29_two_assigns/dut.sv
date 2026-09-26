// § castRhsClonePerInst176
module submodule(input logic [3:0] w);
   assign a = int'(w);
   assign b = shortint'(w) ;
   assign c = w & 4'h1;
endmodule
module top();
   logic [3:0] w;
   submodule u1(w);
   submodule u2(w);
endmodule
