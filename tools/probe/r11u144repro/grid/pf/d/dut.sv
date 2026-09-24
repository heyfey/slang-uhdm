// § callFoldFormalBitSelLoc144
package pkg;
  parameter logic [1:0] P = 2'b10;
endpackage
module top(output a);
   function automatic logic get_first(logic [1:0] x);
      return x[1];
   endfunction
   assign a = get_first(pkg::P);
endmodule
