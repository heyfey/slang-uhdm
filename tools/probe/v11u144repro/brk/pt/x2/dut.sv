// § paramAliasBoundRefUnstored144
module top #(parameter int A = 3, parameter int B = 2)(output int o);
   typedef logic [A+B-1:A-A] my_type_t;
   localparam my_type_t Y = 5;
   my_type_t n;
   assign n = Y;
   assign o = int'(n);
endmodule
