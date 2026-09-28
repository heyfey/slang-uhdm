// (r11u191: copy of tests/probe/r10fiot_repro/a9, the EVALTS control: which actual of the first executed call is stamped)
// r10fiot arm 9 (callee declared BEFORE the caller, so si.argTs is live): which ACTUAL of an in-body call carries the formal's
// typespec, and what stops the run of stamps.
module x1;
  wire [7:0] z; wire [3:0] b;
  assign z = o1(b);
  function [7:0] g1;
    input [2:0] p;
    input [3:0] q;
    g1 = p + q;
  endfunction
  function [7:0] o1;             // local-var SELECT first, plain REF second
    input [3:0] a;
    reg [3:0] lv;
    begin
      lv[3:0] = a;
      o1 = g1(lv[3:1], a);
    end
  endfunction
endmodule
module x2;
  wire [7:0] z; wire [3:0] b;
  assign z = o2(b);
  function [7:0] g2;
    input [2:0] p;
    input [3:0] q;
    g2 = p + q;
  endfunction
  function [7:0] o2;             // local-var SELECT first, OPERATION second
    input [3:0] a;
    reg [3:0] lv;
    begin
      lv[3:0] = a;
      o2 = g2(lv[3:1], ~a);
    end
  endfunction
endmodule
module x3;
  wire [7:0] z; wire [3:0] b;
  assign z = o3(b);
  function [7:0] g3;
    input [3:0] p;
    input [3:0] q;
    g3 = p + q;
  endfunction
  function [7:0] o3;             // plain formal REF first, OPERATION second
    input [3:0] a;
    o3 = g3(a, ~a);
  endfunction
endmodule
module x4;
  wire [7:0] z; wire [3:0] b;
  assign z = o4(b);
  function [7:0] g4;
    input [2:0] p;
    input [3:0] q;
    g4 = p + q;
  endfunction
  function [7:0] o4;             // FORMAL select first, OPERATION second
    input [3:0] a;
    o4 = g4(a[3:1], ~a);
  endfunction
endmodule
module x5;
  wire [7:0] z; wire [3:0] b;
  assign z = o5(b);
  function [7:0] g5;
    input [3:0] p;
    input [3:0] q;
    g5 = p + q;
  endfunction
  function [7:0] o5;             // whole local VAR first, OPERATION second
    input [3:0] a;
    reg [3:0] lv;
    begin
      lv = a;
      o5 = g5(lv, ~a);
    end
  endfunction
endmodule
module x6;
  wire [7:0] z; wire [3:0] b;
  assign z = o6(b);
  function [7:0] g6;
    input [3:0] p;
    input [3:0] q;
    g6 = p + q;
  endfunction
  function [7:0] o6;             // OPERATION actual inside an unfoldable IF
    input [3:0] a;
    begin
      o6 = 0;
      if (a[0]) o6 = g6(a, ~a);
    end
  endfunction
endmodule
