// § aliasCloneTakesTargetFile137
module top();
   typedef struct packed {
      logic x;
   } a;
   typedef a b[5:0];
   b v;
endmodule
