// § castRhsClonePerInst176
module submodule(input logic [3:0] w);
   if (1) begin : g
     assign a = int'(w);
   end
endmodule
module top();
   logic [3:0] w;
   submodule u1(w);
   submodule u2(w);
endmodule
