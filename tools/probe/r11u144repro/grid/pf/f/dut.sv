// § callFoldFormalBitSelLoc144
package pkg;
  parameter logic [1:0] P = {1'b1, 1'b0};
endpackage
module top(output [1:0] a);
   function automatic logic [1:0] get_first(logic [1:0] x);
      return x;
   endfunction
   assign a = get_first(pkg::P);
endmodule
