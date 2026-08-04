// r10fiot arm 3: io_decl typespec presence for BARE formals, by spelling and
// by how the subroutine is reached.
module k1;                       // body-style bare input, function UNCALLED
  function [7:0] f1;
    input a;
    f1 = a;
  endfunction
endmodule

module k2;                       // body-style bare input, called from cont assign
  wire [7:0] z2;
  wire b2;
  assign z2 = f2(b2);
  function [7:0] f2;
    input a;
    f2 = a;
  endfunction
endmodule

module k3;                       // body-style bare input, called in a PARAM init
  parameter P3 = f3(1'b1);
  function [7:0] f3;
    input a;
    f3 = a;
  endfunction
endmodule

module k4;                       // ANSI, direction keyword, no type; UNCALLED
  function [7:0] f4(input a);
    f4 = a;
  endfunction
endmodule

module k5;                       // ANSI, direction keyword, no type; cont assign
  wire [7:0] z5;
  wire b5;
  assign z5 = f5(b5);
  function [7:0] f5(input a);
    f5 = a;
  endfunction
endmodule

module k6;                       // ANSI, direction keyword, no type; PARAM init
  parameter P6 = f6(1'b1);
  function [7:0] f6(input a);
    f6 = a;
  endfunction
endmodule

module k7;                       // body-style RANGED input, uncalled
  function [7:0] f7;
    input [1:0] a;
    f7 = a;
  endfunction
endmodule

module k8;                       // body-style bare input in a TASK
  task t8;
    input a;
    begin
    end
  endtask
endmodule

module k9;                       // body-style bare input, SIGNED variant
  function [7:0] f9;
    input signed a;
    f9 = a;
  endfunction
endmodule

module k10;                      // body-style, two names on one input line
  function [7:0] f10;
    input a, b;
    f10 = a + b;
  endfunction
endmodule
