// § opCtxRefArgBare201 § opCtxBindableTarget201v
module sub (input logic [3:0] a, output logic [3:0] y);
  assign y = a;
endmodule
module o07 (input logic [3:0] a, output logic [3:0] y1, output logic [3:0] y2);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  for (genvar i = 0; i < 2; i++) begin : g
    wire [3:0] w;
    assign w = f(a) + 4'd1;
    assign gi = f(a) | 4'd4;
    sub s (.a(w), .y());
  end
  wire [3:0] late;
  assign late = f(a) - 4'd1;
  assign y1 = g[0].w;
  assign y2 = late;
endmodule
