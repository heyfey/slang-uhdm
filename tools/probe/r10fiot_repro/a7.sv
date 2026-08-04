// r10fiot arm 7: loop bounds and the evaluator's abort.
module v1;                       // for loop bound depends on the FORMAL
  wire [7:0] z; wire [3:0] b;
  assign z = o1(b);
  function [7:0] o1;
    input [3:0] a;
    integer k;
    begin
      o1 = 0;
      for (k = 0; k < a; k = k + 1) o1 = i1(a);
    end
  endfunction
  function [7:0] i1;
    input a;
    i1 = a;
  endfunction
endmodule

module v2;                       // constant for loop, call AFTER it
  wire [7:0] z; wire [3:0] b;
  assign z = o2(b);
  function [7:0] o2;
    input [3:0] a;
    integer k;
    begin
      o2 = 0;
      for (k = 0; k < 2; k = k + 1) o2 = o2 + 1;
      o2 = i2(a);
    end
  endfunction
  function [7:0] i2;
    input a;
    i2 = a;
  endfunction
endmodule

module v3;                       // formal-bound for loop, call AFTER it
  wire [7:0] z; wire [3:0] b;
  assign z = o3(b);
  function [7:0] o3;
    input [3:0] a;
    integer k;
    begin
      o3 = 0;
      for (k = 0; k < a; k = k + 1) o3 = o3 + 1;
      o3 = i3(a);
    end
  endfunction
  function [7:0] i3;
    input a;
    i3 = a;
  endfunction
endmodule

module v4;                       // WHILE loop with a constant condition guard
  wire [7:0] z; wire [3:0] b;
  assign z = o4(b);
  function [7:0] o4;
    input [3:0] a;
    integer k;
    begin
      o4 = 0;
      k = 0;
      while (k < 2) begin
        o4 = i4(a);
        k = k + 1;
      end
    end
  endfunction
  function [7:0] i4;
    input a;
    i4 = a;
  endfunction
endmodule

module v5;                       // REPEAT with a constant count
  wire [7:0] z; wire [3:0] b;
  assign z = o5(b);
  function [7:0] o5;
    input [3:0] a;
    begin
      o5 = 0;
      repeat (2) o5 = i5(a);
    end
  endfunction
  function [7:0] i5;
    input a;
    i5 = a;
  endfunction
endmodule
