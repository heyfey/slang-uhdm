// § opCtxRefArgBare201
module top (input logic c, input logic [3:0] a, input logic [3:0] p1 [4], input logic [7:0] w, output logic [3:0] y1, output logic [3:0] y2, output logic [3:0] y3);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  function automatic logic [3:0] g(input logic [3:0] x); return x ^ 4'h5; endfunction
  wire [3:0] n = f(a) + 4'd1;
  if (1) begin : gi
    assign y1 = f(a) - 4'd1;
  end
  for (genvar i = 0; i < 1; i++) begin : gf
    assign y2 = f(p1[i]) | 4'd1;
  end
  assign y3 = n;
endmodule
