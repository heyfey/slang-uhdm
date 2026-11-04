// § paramAliasBoundRefUnstored144
module top #(parameter int X = 16)(output int o);
   typedef logic [$clog2(X)-1:0] my_type_t;
   parameter my_type_t Y = '1;
   assign o = int'(Y);
endmodule
