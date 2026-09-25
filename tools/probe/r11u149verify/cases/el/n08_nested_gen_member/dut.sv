// § elabCloneInstTreeUnstored144 (--elabuhdm)
module dut(input logic [3:0] a, output logic [3:0] y);
  for (genvar i = 0; i < 2; i++) begin : O
    for (genvar j = 0; j < 2; j++) begin : I
      logic t;
      assign t = a[i*2+j];
    end
    assign y[i*2] = O[i].I[0].t;
    assign y[i*2+1] = O[i].I[1].t;
  end
endmodule
