// § callFoldFormalBitSelLoc144
module top(output a, output b, output c);
   function automatic logic f1(logic [3:0] x);
      return ~x[1];
   endfunction
   function automatic logic f2(logic [3:0] x);
      return x[1] ^ x[0];
   endfunction
   function automatic logic f3(logic [3:0] x);
      logic r;
      r = x[2];
      return r;
   endfunction
   assign a = f1(4'b0010);
   assign b = f2(4'b0011);
   assign c = f3(4'b0100);
endmodule
