module top(output logic [31:0] o0, output logic [31:0] o1, output logic [31:0] o2);
  for (genvar g = 0; g < 3; g++) begin : gb
    if (g == 0) begin : a0
      assign o0 = (g < 2) ? (32'd10 + g) : '0;
    end
    if (g == 1) begin : a1
      assign o1 = (g < 2) ? (32'd10 + g) : '0;
    end
    if (g == 2) begin : a2
      assign o2 = (g < 2) ? (32'd10 + g) : '0;
    end
  end
endmodule
