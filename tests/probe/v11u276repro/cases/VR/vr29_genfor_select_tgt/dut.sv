// § caReduceOpKindGate276
module dut #(parameter logic [7:0] P = 8'h3C, parameter logic [7:0] Q = 8'hA5) (input logic [7:0] n, m, output logic [7:0] o);
  logic [7:0] t;
  for (genvar i = 0; i < 8; i++) begin : g
    assign t[i] = (P[i] & n[i]) ^ (Q[i] | m[i]);
  end
  assign o = t;
endmodule
