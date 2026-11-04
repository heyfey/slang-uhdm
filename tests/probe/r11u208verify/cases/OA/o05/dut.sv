// § opCtxRefArgBare201 § opCtxBindableTarget201v
module child (input logic [3:0] a);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign o05.up = f(a) + 4'd1;
endmodule
module o05 (input logic [3:0] a, output logic [3:0] y);
  wire [3:0] up;
  child c (.a(a));
  assign y = up;
endmodule
