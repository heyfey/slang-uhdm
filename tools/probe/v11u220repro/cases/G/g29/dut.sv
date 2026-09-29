// § hpVarSelRangeIdxNamesByPath220
module top(input logic [65:0] din, output logic [7:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t [1:0] q;
  assign q = din;
  for (genvar g = 0; g < 4; g++) begin : gl
    logic [1:0] w;
    assign w = q[g/2].arr[g][g%2+:2];
    assign o[g*2+:2] = w;
  end
endmodule
