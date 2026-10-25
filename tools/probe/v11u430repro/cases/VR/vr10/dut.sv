// § defGenLpRangedTs430
module sub #(parameter N = 2) (input [3:0] i, output [3:0] o);
  for (genvar k = 0; k < N; k++) begin : g
    localparam [31:0] a = k * 2;
    assign o[k] = i[a];
  end
endmodule
module top (input [3:0] i, output [3:0] o); sub #(.N(2)) u(.i(i), .o(o)); endmodule
