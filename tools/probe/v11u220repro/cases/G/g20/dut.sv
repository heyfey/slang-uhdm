// § hpVarSelRangeIdxNamesByPath220
module top(input logic [65:0] din, output logic [3:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t [1:0] q;
  assign q = din;
  for (genvar i = 0; i < 2; i++) begin : gi
    for (genvar j = 0; j < 2; j++) begin : gj
      assign o[i*2+j] = q[i].arr[j][0:0];
    end
  end
endmodule
