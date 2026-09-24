// § foldedBoundTsRefUnstored144
module top #(parameter int P = 3)(input logic [P:0] i, output int o);
   function automatic int f(input logic [P:0] a);
      logic [P:0] tmp;
      tmp = a;
      return int'(tmp);
   endfunction
   assign o = f(i);
endmodule
