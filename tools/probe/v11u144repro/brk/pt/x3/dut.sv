// § paramAliasBoundRefUnstored144
module top #(parameter int X = 4)(output int o);
   typedef struct packed { logic [X-1:0] a; logic b; } my_type_t;
   parameter my_type_t Y = '0;
   assign o = int'(Y.a);
endmodule
