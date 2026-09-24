// § contAssignLhsTsUnparented134
interface ifc;
   typedef struct packed {
      logic [3:0] x;
   } s_t;
   s_t a;
   assign a = '0;
endinterface
module top;
   ifc i();
endmodule
