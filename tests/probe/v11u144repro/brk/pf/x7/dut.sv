// § callFoldFormalBitSelLoc144
module top(output a, output b);
   localparam logic [3:0] K = 4'b1000;
   function automatic logic g(logic [3:0] x);
      return x[3];
   endfunction
   assign a = g(K);
   assign b = g(K + 4'd1);
endmodule
