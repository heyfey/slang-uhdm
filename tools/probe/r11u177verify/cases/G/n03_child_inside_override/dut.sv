// § gcaChainInsideSetKeepsInst169v
module child #(parameter int P = 6) (input logic [31:0] a [2], output logic [31:0] o [2]);
  localparam int Q = P * 2;
  for (genvar c = 0; c < 2; c++) begin : g
    assign o[c] = 32'(a[c] inside {[P:Q], P + 1}) + (a[c] & P);
  end
endmodule
module dut (input logic [31:0] a [2], output logic [31:0] o [2]);
  child #(.P(2)) u (.a(a), .o(o));
endmodule
