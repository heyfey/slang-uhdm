// § caLvTrailIdxNamesByPath264
module top(input logic [3:0] a, output logic [3:0] o);
  typedef struct packed { logic q; } f_t;
  f_t [3:0] w;
  for (genvar k = 0; k < 4; k++) begin : g
    assign w[k].q = a[k];
  end
  assign o = w;
endmodule
