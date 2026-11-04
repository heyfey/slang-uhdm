// § callFoldFormalBitSelLoc144
module top(output a);
   localparam logic [1:0] P = {1'b1, 1'b0};
   function automatic logic get_first(logic [1:0] x);
      return x[1];
   endfunction
   assign a = get_first(P);
endmodule
