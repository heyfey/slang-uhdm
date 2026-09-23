module m #(parameter bit EN = 1) (input logic [15:0] rd [2], input logic [3:0] o, output logic [3:0] y [2]);
  if (EN) begin : ge
    for (genvar i = 0; i < 2; i++) begin : gl
      assign y[i] = rd[i][o +: 4];
    end
  end
endmodule
