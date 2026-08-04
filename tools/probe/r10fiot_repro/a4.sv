// r10fiot arm 4: bare-formal io_decl typespec -- signing, scope and reach.
package pk4;
  function [7:0] pf1;            // package fn, bare body-style, UNCALLED
    input a;
    pf1 = a;
  endfunction
endpackage

module q1;                       // body-style SIGNED bare input, CALLED (cont assign)
  wire [7:0] z1;
  wire b1;
  assign z1 = f1(b1);
  function [7:0] f1;
    input signed a;
    f1 = a;
  endfunction
endmodule

module q2;                       // body-style bare input, called from an ALWAYS block
  reg [7:0] z2;
  wire b2;
  always @(*) z2 = f2(b2);
  function [7:0] f2;
    input a;
    f2 = a;
  endfunction
endmodule

module q3;                       // body-style bare input, called from another FUNCTION
  wire [7:0] z3;
  wire b3;
  assign z3 = f3outer(b3);
  function [7:0] f3outer;
    input a;
    f3outer = f3inner(a);
  endfunction
  function [7:0] f3inner;
    input a;
    f3inner = a;
  endfunction
endmodule

module q4;                       // ANSI bare NAME (no direction), uncalled
  function [7:0] f4(a);
    f4 = a;
  endfunction
endmodule

module q5;                       // body-style `input wire a;` (explicit net kw)
  function [7:0] f5;
    input reg a;
    f5 = a;
  endfunction
endmodule

module q6;                       // body-style bare INOUT/OUTPUT in a task, uncalled
  task t6;
    output a;
    inout b;
    begin
    end
  endtask
endmodule
