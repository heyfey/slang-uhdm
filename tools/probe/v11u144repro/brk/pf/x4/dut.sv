// § callFoldFormalBitSelLoc144
module top(output a, output b);
   function automatic logic pick(logic [3:0] x, int k);
      return x[k];
   endfunction
   function automatic logic first2(logic [3:0] x, logic [3:0] y);
      return y[0];
   endfunction
   assign a = pick(4'b1010, 1);
   assign b = first2(4'b0000, 4'b0001);
endmodule
