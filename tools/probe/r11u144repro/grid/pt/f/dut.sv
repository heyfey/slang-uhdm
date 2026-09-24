// § paramAliasBoundRefUnstored144
module top(output int o);
   parameter int X = 20;
   typedef logic [X-1:0] my_type_t;
   my_type_t Y;
   assign Y = '1;
   assign o = int'(Y);
endmodule
