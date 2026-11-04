// § foldedBoundTsRefUnstored144
module sub #(parameter int D = 5)(output int o);
   logic [D:0] v;
   assign v = '0;
   assign o = int'(v);
endmodule
module top(output int o);
   sub u(.o(o));
endmodule
