// § aliasCloneTakesTargetFile137
package pkg;
   typedef struct packed {
      logic x;
      logic [3:0] y;
   } a;
   typedef a b[1:0];
endpackage
module top();
  import pkg::*;
  b v;
endmodule
