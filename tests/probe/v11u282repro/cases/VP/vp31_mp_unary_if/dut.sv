// § genProcUnaryFoldInst282
module top #(parameter int P = 4) (input logic [7:0] a, output logic [7:0] z);
  if (P > 1) begin : gi
    always_comb if (a != ~P) z = -P; else z = !P;
  end
endmodule
