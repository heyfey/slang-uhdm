// § cloneTfItemLocalOwnVar253 (a Verilog-2001 style function: body io, a reg local)
package p;
  function [7:0] f;
    input [7:0] a;
    input [7:0] b;
    reg [7:0] t;
    begin
      t = a ^ b;
      f = t;
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
