// § opCtxRefArgBare201 § opCtxBindableTarget201v
module chk (input logic [3:0] a);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  wire [3:0] q;
  assign q = f(a) + 4'd1;
endmodule
module sub (input logic [3:0] a, output logic [3:0] y);
  assign y = a;
endmodule
module o02 (input logic [3:0] a, output logic [3:0] y);
  sub s (a, y);
  bind sub chk c (.a(a));
endmodule
