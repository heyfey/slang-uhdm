// § callFoldFormalBitSelLoc144
package pkg;
  parameter logic [3:0] P = {2{2'b10}};
  parameter logic [3:0] Q = {2'b10, {2{1'b1}}};
endpackage
module top(output a, output b);
   function automatic logic get_first(logic [3:0] x);
      return x[3];
   endfunction
   assign a = get_first(pkg::P);
   assign b = get_first(pkg::Q);
endmodule
