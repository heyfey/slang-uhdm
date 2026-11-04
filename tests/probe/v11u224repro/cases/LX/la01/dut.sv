// § hpLvSelIdxNamesByPath224
module top(input logic [1:0] i, input logic [1:0] d, output logic [32:0] o);
  typedef struct packed { logic [3:0][7:0] arr; logic v; } s_t;
  for (genvar g1 = 0; g1 < 2; g1++) begin : a
    for (genvar g2 = 0; g2 < 2; g2++) begin : b
      s_t s;
      always_comb begin
        s = '0;
        s.arr[i][1:0] = d;
      end
    end
  end
  assign o = a[0].b[1].s;
endmodule
