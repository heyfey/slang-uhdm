// § sysCtxRefArgBare201
program prg (input logic [3:0] a);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  int n;
  initial n = $countones(f(a));
  assign n2 = $countones(f(a));
endprogram
module s04 (input logic [3:0] a, output int y);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  always_comb y = $countones(f(a[3:0])) + $countones(f(a));
  prg p (a);
endmodule
