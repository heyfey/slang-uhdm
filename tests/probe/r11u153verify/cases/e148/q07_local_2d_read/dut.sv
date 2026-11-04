// § evalFuncSelectKeepsCall148
module top(input logic [1:0] a, output logic o);
   function automatic logic theta(logic [1:0] x);
      logic [1:0][1:0] t;
      t[0] = x;
      t[1] = ~x;
      return t[1][0];
   endfunction
   assign o = theta(a);
endmodule
