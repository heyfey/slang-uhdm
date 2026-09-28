// § opCtxRefArgBare201 § opCtxBindableTarget201v
program prg (input logic [3:0] a, output logic [3:0] y);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign y = f(a) + 4'd1;
endprogram
module o04 (input logic [3:0] a, output logic [3:0] y, output logic [3:0] z);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  prg p (a, y);
  assign z = f(a) + f(a);
  typedef struct packed { logic [1:0] h; logic [1:0] l; } s_t;
  s_t s;
  assign s = f(a) + 4'd3;
endmodule
