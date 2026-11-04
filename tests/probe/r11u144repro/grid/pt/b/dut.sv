// § paramAliasBoundRefUnstored144
module sub #(parameter int X = 4)(output int o);
   typedef logic [X-1:0] my_type_t;
   parameter my_type_t Y = '1;
   assign o = int'(Y);
endmodule
module top(output int o1, output int o2);
   sub u1(.o(o1));
   sub #(.X(8)) u2(.o(o2));
endmodule
