// § paramAliasBoundRefUnstored144
module top #(parameter int X = 4)(output int o);
   typedef logic signed [X-1:0] my_type_t;
   typedef my_type_t [1:0] arr_t;
   parameter arr_t Y = '0;
   parameter my_type_t Z = -1;
   assign o = int'(Y) + int'(Z);
endmodule
