// § cloneTfItemLocalOwnVar253 (downstream: a Verilog-2001 function with body io and a reg local, called through an importer)
package p;
  function [7:0] mix;
    input [7:0] a;
    input [7:0] b;
    reg [7:0] t;
    begin
      t = a ^ b;
      mix = t + 8'd1;
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top(input logic [7:0] a, input logic [7:0] b, output logic [7:0] y);
  import p::*;
  assign y = mix(a, b);
endmodule
