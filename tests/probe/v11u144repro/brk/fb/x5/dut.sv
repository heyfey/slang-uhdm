// § foldedBoundTsRefUnstored144
module sub #(parameter int N = 2)(output int o);
   logic [N-1:0] q;
   for (genvar i = 0; i < 2; i++) begin : g
     logic [N:0] r;
     assign r = '0;
   end
   assign q = '1;
   assign o = int'(q);
endmodule
module top(output int o1, o2);
   sub #(.N(3)) u1(.o(o1));
   sub u2(.o(o2));
endmodule
