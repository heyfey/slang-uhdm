// § callFoldFormalBitSelLoc144
package pkg;
  parameter logic [3:0] P = {2'b11, 2'b0};
endpackage
module top(output [1:0] a);
   function automatic logic [1:0] get_first(logic [3:0] x);
      return x[3:2];
   endfunction
   assign a = get_first(pkg::P);
endmodule
