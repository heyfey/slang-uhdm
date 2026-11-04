`define GEN(N) \
  for (genvar i = 0; i < N; i++) begin : g \
    assign o[i] = a[i]; \
  end
