// § hpLvSelIdxNamesByPath224
module top(input logic [1:0] i, input logic [1:0] d, output logic [32:0] o[2]);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  for (genvar g = 0; g < 2; g++) begin : gb
    s_t s;
    always_comb begin
      s = '0;
      s.arr[i][1:0] = d;
    end
    assign o[g] = s;
  end
endmodule
