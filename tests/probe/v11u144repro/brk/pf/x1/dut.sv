// § callFoldFormalBitSelLoc144
module top(output a, output b);
   function automatic logic get_first(logic [3:0] x);
      return x[2];
   endfunction
   assign a = get_first(5);
   assign b = get_first(
        4'hC);
endmodule
