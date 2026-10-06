// § caLvTrailIdxNamesByPath264
module top(input logic [3:0] a, output logic o);
  typedef struct { logic en [4]; } w_t;
  w_t w;
  for (genvar k = 0; k < 4; k++) begin : g
    assign w.en[k] = a[k];
  end
  assign o = w.en[0];
endmodule
