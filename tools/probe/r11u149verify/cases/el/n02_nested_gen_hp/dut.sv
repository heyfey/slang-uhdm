// § elabCloneInstTreeUnstored144 (--elabuhdm)
module dut(input logic [3:0] a, output logic [3:0] y);
  for (genvar i = 0; i < 2; i++) begin : O
    for (genvar j = 0; j < 2; j++) begin : I
      logic t;
      if (i == 0 && j == 0) begin : B
        assign t = a[0];
      end else begin : B
        assign t = O[i].I[j - (j > 0 ? 1 : 0)].t ^ a[i*2+j];
      end
      assign y[i*2+j] = t;
    end
  end
endmodule
