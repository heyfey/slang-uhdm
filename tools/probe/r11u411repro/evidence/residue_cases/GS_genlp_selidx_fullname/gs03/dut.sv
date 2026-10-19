// residue (not written): generate-localparam select index full name and fold
module top #(parameter logic [7:0] M = 8'h5A) (input logic [7:0] x, output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : rof
    wire w = x[i];
    assign o[i] = w ^ M[i];
  end
endmodule
