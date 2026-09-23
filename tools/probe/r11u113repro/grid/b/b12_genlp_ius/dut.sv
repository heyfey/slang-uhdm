module top (input logic [7:0] i, output logic [7:0] o);
  if (1) begin : g
    localparam int unsigned P = 5;
    logic [P:0] x;
    assign x = i[5:0];
    assign o = x;
  end
endmodule
