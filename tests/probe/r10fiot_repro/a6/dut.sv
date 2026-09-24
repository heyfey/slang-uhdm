// r10fiot arm 6: where exactly does the body descent abort?
module u1;                       // call inside an if with a CONSTANT condition
  wire [7:0] z; wire b;
  assign z = o1(b);
  function [7:0] o1;
    input a;
    begin
      if (1'b1) o1 = i1(a);
      else      o1 = 0;
    end
  endfunction
  function [7:0] i1;
    input a;
    i1 = a;
  endfunction
endmodule

module u2;                       // call AFTER an unevaluatable if
  wire [7:0] z; wire b;
  reg [7:0] q2;
  assign z = o2(b);
  function [7:0] o2;
    input a;
    reg t;
    begin
      if (a) t = 1;
      else   t = 0;
      o2 = i2(a);
    end
  endfunction
  function [7:0] i2;
    input a;
    i2 = a;
  endfunction
endmodule

module u3;                       // call inside a FOR loop
  wire [7:0] z; wire b;
  assign z = o3(b);
  function [7:0] o3;
    input a;
    integer k;
    begin
      o3 = 0;
      for (k = 0; k < 2; k = k + 1) o3 = i3(a);
    end
  endfunction
  function [7:0] i3;
    input a;
    i3 = a;
  endfunction
endmodule

module u4;                       // call inside a CASE
  wire [7:0] z; wire b;
  assign z = o4(b);
  function [7:0] o4;
    input a;
    begin
      case (a)
        1'b0: o4 = i4(a);
        default: o4 = 0;
      endcase
    end
  endfunction
  function [7:0] i4;
    input a;
    i4 = a;
  endfunction
endmodule

module u5;                       // call BEFORE an unevaluatable if
  wire [7:0] z; wire b;
  assign z = o5(b);
  function [7:0] o5;
    input a;
    reg t;
    begin
      o5 = i5(a);
      if (a) t = 1;
      else   t = 0;
    end
  endfunction
  function [7:0] i5;
    input a;
    i5 = a;
  endfunction
endmodule

module u6;                       // TWO calls in one direct statement
  wire [7:0] z; wire b;
  assign z = o6(b);
  function [7:0] o6;
    input a;
    o6 = i6a(a) + i6b(a);
  endfunction
  function [7:0] i6a;
    input a;
    i6a = a;
  endfunction
  function [7:0] i6b;
    input a;
    i6b = a;
  endfunction
endmodule
