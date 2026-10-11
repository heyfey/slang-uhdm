// § foldIntTsSignedKwTrim286 — int signed parameter overridden by the instance; nested generate
module sub #(parameter int signed P = 3) (input logic [63:0] a [2], output logic [63:0] o1 [2]);
  for (genvar c = 0; c < 2; c++) begin : g
    for (genvar k = 0; k < 1; k++) begin : h
      assign o1[c] = a[c] ^ P;
    end
  end
endmodule
module dut (input logic [63:0] a [2], output logic [63:0] o1 [2], output logic [63:0] o2 [2]);
  sub #(.P(-9)) u1 (.a(a), .o1(o1));
  sub u2 (.a(a), .o1(o2));
endmodule
