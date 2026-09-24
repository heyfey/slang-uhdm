// § paramAliasBoundRefUnstored144
module top(output int o);
   parameter int X = 20;
   typedef logic [X-1:0] my_type_t;
   typedef my_type_t my2_t;
   parameter my2_t Y = '1;
   assign o = int'(Y);
endmodule
