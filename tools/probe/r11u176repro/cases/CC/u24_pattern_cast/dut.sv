// § castRhsClonePerInst176
module submodule(input logic [3:0] w);
   typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
   assign a = s_t'{w, w};
endmodule
module top();
   logic [3:0] w;
   submodule u1(w);
   submodule u2(w);
endmodule
