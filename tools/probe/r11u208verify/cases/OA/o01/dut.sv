// § opCtxRefArgBare201 § opCtxBindableTarget201v
module child (input logic [3:0] a, output logic [3:0] y);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign y = f(a) + 4'd1;
  wire [3:0] cw;
endmodule
module o01 (input logic [3:0] a, output logic [3:0] y1, output logic [3:0] y2);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  wire [3:0] n;
  logic [3:0] v;
  child u (.a(a), .y(y2));
  assign n = f(a) + 4'd2;
  assign v = f(a) - n;
  assign u.cw = f(a) | 4'd1;
  assign y1 = v;
endmodule
