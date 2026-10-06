// § sysArgFoldTsUnitName261
package hp;
  parameter int NumRound = 64;
  parameter logic [7:0] W8 = 8'd12;
endpackage
module sha2 import hp::*; (input logic clk, output logic o);
  function automatic logic f(input logic a);
    logic [$clog2(NumRound)-1:0] t;
    t = '0;
    return a ^ t[0];
  endfunction
  assign o = f(clk);
endmodule
module top;
  logic o;
  sha2 u (.clk(1'b0), .o(o));
endmodule
