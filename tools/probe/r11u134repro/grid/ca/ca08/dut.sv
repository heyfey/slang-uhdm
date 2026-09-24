// § contAssignLhsTsUnparented134
module top(input logic [7:0] i);
   typedef union packed {
      logic [7:0] b;
      logic [7:0] c;
   } u_t;
   u_t m;
   assign m = i;
endmodule
