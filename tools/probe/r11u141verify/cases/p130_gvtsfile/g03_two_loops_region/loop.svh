  generate
    for (genvar i = 0; i < 1; i++) begin : ga
      assign y[i] = a[i];
    end
    for (genvar k = 1; k < 2; k++) begin : gb
      assign y[k] = a[k];
    end
  endgenerate
