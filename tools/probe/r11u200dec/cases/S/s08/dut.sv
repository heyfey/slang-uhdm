module s08;
  bit  [3:0] v1;
  function bit  [3:0] f1(input int a); return a; endfunction
  bit signed [3:0] v2;
  function bit signed [3:0] f2(input int a); return a; endfunction
  bit unsigned [3:0] v3;
  function bit unsigned [3:0] f3(input int a); return a; endfunction
  logic  [3:0] v4;
  function logic  [3:0] f4(input int a); return a; endfunction
  logic signed [3:0] v5;
  function logic signed [3:0] f5(input int a); return a; endfunction
  logic unsigned [3:0] v6;
  function logic unsigned [3:0] f6(input int a); return a; endfunction
  reg  [3:0] v7;
  function reg  [3:0] f7(input int a); return a; endfunction
  reg signed [3:0] v8;
  function reg signed [3:0] f8(input int a); return a; endfunction
  reg unsigned [3:0] v9;
  function reg unsigned [3:0] f9(input int a); return a; endfunction
endmodule
