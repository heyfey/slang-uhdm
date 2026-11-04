// § defNetTypedefEndWrite134
interface ifc;
   typedef struct packed {
      logic [7:0] x;
   } s_t;
   s_t a[2];
endinterface
module top;
   ifc i();
endmodule
