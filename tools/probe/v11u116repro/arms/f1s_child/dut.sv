module sub #(parameter int unsigned P = 32'h0000_00FF) (input logic [31:0] a [2], output logic [31:0] o [2]);
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = a[c] & ~P;
  end
endmodule
module dut (input logic [31:0] a [2], output logic [31:0] o [2], output logic [31:0] q [2]);
  sub #(.P(32'h0000_0FFF)) u1 (.a(a), .o(o));
  sub u2 (.a(a), .o(q));
endmodule
