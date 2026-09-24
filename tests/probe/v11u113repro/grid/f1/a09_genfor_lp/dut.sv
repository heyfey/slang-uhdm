module top (input logic [7:0] i, output logic [7:0] o [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    localparam int unsigned P = k + 3;
    logic [P:0] x;
    assign x = i[P:0];
    assign o[k] = x;
  end
endmodule
