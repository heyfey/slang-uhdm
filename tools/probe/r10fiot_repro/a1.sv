// r10fiot arm 1: implicit-net creation matrix.  Each module isolates ONE
// identifier position; names are unique per module so a net in one cannot be
// confused with a net in another.
module m1;                       // fn-local param in a fn-local reg RANGE
  function [7:0] f1;
    input a;
    parameter p1 = 4;
    reg [p1-1:0] r1;
    f1 = r1;
  endfunction
endmodule

module m2;                       // fn-local param in the fn BODY only
  function [7:0] f2;
    input a;
    parameter p2 = 4;
    f2 = p2;
  endfunction
endmodule

module m3;                       // MODULE param in a fn-local reg range
  parameter q3 = 4;
  function [7:0] f3;
    input a;
    reg [q3-1:0] r3;
    f3 = r3;
  endfunction
endmodule

module m4;                       // fn-local param in an IO_DECL range
  function [7:0] f4;
    parameter p4 = 4;
    input [p4-1:0] a;
    f4 = a;
  endfunction
endmodule

module m5;                       // fn-local param in the RETURN range
  function [p5-1:0] f5;
    input a;
    parameter p5 = 4;
    f5 = a;
  endfunction
endmodule

module m6;                       // fn-local param in TWO reg ranges
  function [7:0] f6;
    input a;
    parameter p6 = 4;
    reg [p6-1:0] r6a;
    reg [p6-1:0] r6b;
    f6 = r6a + r6b;
  endfunction
endmodule

module m7;                       // fn-local REG name in another reg's range
  function [7:0] f7;
    input a;
    reg [3:0] w7;
    reg [w7-1:0] r7;
    f7 = r7;
  endfunction
endmodule

module m8;                       // TASK-local param in a task-local reg range
  task t8;
    input a;
    parameter p8 = 4;
    reg [p8-1:0] r8;
    begin
      r8 = a;
    end
  endtask
endmodule

module m9;                       // name ALSO declared as a module net
  wire [3:0] p9;
  function [7:0] f9;
    input a;
    parameter p9 = 4;
    reg [p9-1:0] r9;
    f9 = r9;
  endfunction
endmodule

module m10;                      // fn-local param in a reg range inside begin
  function [7:0] f10;
    input a;
    parameter p10 = 4;
    reg [p10-1:0] r10;
    begin
      r10 = a;
      f10 = r10;
    end
  endfunction
endmodule
