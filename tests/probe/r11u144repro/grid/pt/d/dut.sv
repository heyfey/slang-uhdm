// § paramAliasBoundRefUnstored144
module top(output int o);
   parameter int X = 20;
   parameter int Z = 2;
   typedef logic [X+Z-1:0] my_type_t;
   parameter my_type_t Y = '1;
   assign o = int'(Y);
endmodule
