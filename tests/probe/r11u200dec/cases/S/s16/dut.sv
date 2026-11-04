module s16;
  for (genvar k1 = 0; k1 < 2; k1++) begin : g1
    bit  x;
  end
  for (genvar k2 = 0; k2 < 2; k2++) begin : g2
    bit signed x;
  end
  for (genvar k3 = 0; k3 < 2; k3++) begin : g3
    bit unsigned x;
  end
  for (genvar k4 = 0; k4 < 2; k4++) begin : g4
    logic  x;
  end
  for (genvar k5 = 0; k5 < 2; k5++) begin : g5
    logic signed x;
  end
  for (genvar k6 = 0; k6 < 2; k6++) begin : g6
    logic unsigned x;
  end
  for (genvar k7 = 0; k7 < 2; k7++) begin : g7
    reg  x;
  end
  for (genvar k8 = 0; k8 < 2; k8++) begin : g8
    reg signed x;
  end
  for (genvar k9 = 0; k9 < 2; k9++) begin : g9
    reg unsigned x;
  end
  for (genvar k10 = 0; k10 < 2; k10++) begin : g10
    int  x;
  end
  for (genvar k11 = 0; k11 < 2; k11++) begin : g11
    int signed x;
  end
  for (genvar k12 = 0; k12 < 2; k12++) begin : g12
    int unsigned x;
  end
  for (genvar k13 = 0; k13 < 2; k13++) begin : g13
    byte  x;
  end
  for (genvar k14 = 0; k14 < 2; k14++) begin : g14
    byte signed x;
  end
  for (genvar k15 = 0; k15 < 2; k15++) begin : g15
    byte unsigned x;
  end
endmodule
