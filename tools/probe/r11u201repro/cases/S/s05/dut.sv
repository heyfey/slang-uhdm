// § sysCtxRefArgBare201
module top (input logic c, input logic [3:0] a, input logic [3:0] p1 [4], input logic [7:0] w, output logic [3:0] y1, output logic [3:0] y2, output logic [3:0] y3, output logic [31:0] y4);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  for (genvar i = 0; i < 2; i++) begin : g
    logic [3:0] z;
    assign z = 4'($countones(f(p1[i])));
  end
  if (1) begin : h
    assign y1 = 4'($countones(f(w[7:4])));
  end
endmodule
