module m #(parameter logic [7:0] X = 8'hab)(output int a);
   assign a = X;
endmodule
module top(output int o);
   m u(.a(o));
endmodule
