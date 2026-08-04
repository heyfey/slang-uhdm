// r10fiot arm 2: the dangling-vs-implicit-net boundary.
module n1;                     // fn-local param init refs another fn-local param
  function [7:0] g1;
    input a;
    parameter x1 = 4;
    parameter y1 = x1 + 1;
    g1 = a;
  endfunction
endmodule

module n2;                     // fn-local param init refs a MODULE param
  parameter mx2 = 4;
  function [7:0] g2;
    input a;
    parameter y2 = mx2 + 1;
    g2 = a;
  endfunction
endmodule

module n3;                     // MODULE-scope reg range refs an undeclared name
  reg [z3-1:0] r3;
endmodule

module n4;                     // fn-local param in a range; module has a VAR of that name
  reg [3:0] p4;
  function [7:0] g4;
    input a;
    parameter p4 = 4;
    reg [p4-1:0] r4;
    g4 = r4;
  endfunction
endmodule

module n5;                     // fn-local param in a range AND in the body
  function [7:0] g5;
    input a;
    parameter p5 = 4;
    reg [p5-1:0] r5;
    g5 = r5 + p5;
  endfunction
endmodule

module n6;                     // fn-local param in a range; module PARAM of that name
  parameter p6 = 9;
  function [7:0] g6;
    input a;
    parameter p6 = 4;
    reg [p6-1:0] r6;
    g6 = r6;
  endfunction
endmodule

module n7;                     // same fn-local param name in TWO functions
  function [7:0] g7a;
    input a;
    parameter p7 = 4;
    reg [p7-1:0] r7a;
    g7a = r7a;
  endfunction
  function [7:0] g7b;
    input a;
    parameter p7 = 5;
    reg [p7-1:0] r7b;
    g7b = r7b;
  endfunction
endmodule

module n8;                     // localparam (not parameter) inside a function
  function [7:0] g8;
    input a;
    localparam p8 = 4;
    reg [p8-1:0] r8;
    g8 = r8;
  endfunction
endmodule

module n9;                     // fn-local param used in a PART-SELECT in the body
  function [7:0] g9;
    input [7:0] a;
    parameter p9 = 4;
    g9 = a[p9-1:0];
  endfunction
endmodule
