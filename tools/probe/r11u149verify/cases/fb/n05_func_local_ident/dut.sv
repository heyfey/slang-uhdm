// § foldedBoundTsRefUnstored144
module top(input logic [5:0] a, output int o);
   localparam int D = 5;
   function automatic int f(input logic [5:0] x);
      logic [D:0] t;
      t = x;
      return int'(t);
   endfunction
   assign o = f(a);
endmodule
