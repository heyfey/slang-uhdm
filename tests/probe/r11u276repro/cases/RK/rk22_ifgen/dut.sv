// § caReduceOpKindGate276
module dut #(parameter logic [7:0] P = 8'h3C, parameter bit E = 1) (input logic [7:0] n, n2, output logic [7:0] o);
  if (E) begin : g
    assign o = (P[3:0] & n[3:0]) ^ n2;
  end else begin : h
    assign o = n2;
  end
endmodule
