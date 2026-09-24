  genvar j;
  for (j = 0; j < 2; j = j + 1) begin : gl
    assign y[j] = ~a[j];
  end
