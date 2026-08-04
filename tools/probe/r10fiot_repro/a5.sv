// r10fiot arm 5: how far does the "formals get compiled" reach travel?
module s1;                       // inner called from outer's DIRECT stmt
  wire [7:0] z; wire b;
  assign z = o1(b);
  function [7:0] o1;
    input a;
    o1 = i1(a);
  endfunction
  function [7:0] i1;
    input a;
    i1 = a;
  endfunction
endmodule

module s2;                       // inner called from inside a BEGIN in outer
  wire [7:0] z; wire b;
  assign z = o2(b);
  function [7:0] o2;
    input a;
    begin
      o2 = i2(a);
    end
  endfunction
  function [7:0] i2;
    input a;
    i2 = a;
  endfunction
endmodule

module s3;                       // inner called from inside an IF in outer
  wire [7:0] z; wire b;
  assign z = o3(b);
  function [7:0] o3;
    input a;
    begin
      if (a) o3 = i3(a);
      else   o3 = 0;
    end
  endfunction
  function [7:0] i3;
    input a;
    i3 = a;
  endfunction
endmodule

module s4;                       // three-deep DIRECT chain
  wire [7:0] z; wire b;
  assign z = o4(b);
  function [7:0] o4;
    input a;
    o4 = m4(a);
  endfunction
  function [7:0] m4;
    input a;
    m4 = i4(a);
  endfunction
  function [7:0] i4;
    input a;
    i4 = a;
  endfunction
endmodule

module s5;                       // outer called from an ALWAYS block, inner direct
  reg [7:0] z; wire b;
  always @(*) z = o5(b);
  function [7:0] o5;
    input a;
    o5 = i5(a);
  endfunction
  function [7:0] i5;
    input a;
    i5 = a;
  endfunction
endmodule

module s6;                       // outer body has a BEGIN whose FIRST stmt is the call
  wire [7:0] z; wire b;
  assign z = o6(b);
  function [7:0] o6;
    input a;
    reg t;
    begin
      t = a;
      o6 = i6(t);
    end
  endfunction
  function [7:0] i6;
    input a;
    i6 = a;
  endfunction
endmodule
