`define tie(RIF) \
    for (genvar i = 0; i < 2; i++) begin : g \
      assign RIF.read_data[i+1] = 1'b0; \
    end
