// § hpLvSelIdxNamesByPath224
module top(input logic [1:0] i, input logic [1:0] d, output logic [32:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  s_t s;
  for (genvar g = 0; g < 2; g++) begin : gb
    if (g == 1) begin : gi
      always_comb begin
        s = '0;
        s.arr[i][1:0] = d;
      end
    end
  end
  assign o = s;
endmodule
