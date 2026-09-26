// § castRhsClonePerInst176
module submodule(input logic w, input logic v);
   assign d = w ? v : 1'b0;
endmodule
module top();
   logic w, v;
   submodule u1(w, v);
   submodule u2(w, v);
endmodule
