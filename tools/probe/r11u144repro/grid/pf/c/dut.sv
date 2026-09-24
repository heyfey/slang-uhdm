// § callFoldFormalBitSelLoc144
module top(output a);
   function automatic logic get_first(logic [1:0] x);
      return x[1];
   endfunction
   assign a = get_first(2'b10);
endmodule
