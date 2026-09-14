module top(input logic [31:0] a, output logic [31:0] o0, output logic [31:0] o1);
  for (genvar g = 0; g < 2; g++) begin : gb
    if (g == 0) begin : gi
      assign o0 = (g == 0) ? g : '0;
    end else begin : gi
      assign o1 = (g == 0) ? g : '0;
    end
  end
endmodule
