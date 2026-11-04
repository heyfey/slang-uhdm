// § foldedBoundTsRefUnstored144
module top #(parameter int P = 4)(input logic [P-1:0] a, output int o);
   localparam int D = 3;
   wire [D:0] w = a[D:0];
   logic [P+D:D] v;
   assign v = '0;
   assign o = int'(w) + int'(v);
endmodule
