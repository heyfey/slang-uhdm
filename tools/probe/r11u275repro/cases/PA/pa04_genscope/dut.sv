// § tpPackedArrCaUnparent275 — the assignment inside a generate scope
module dut #(parameter type T = struct packed { logic [1:0] a; logic b; } [1:0]) (input logic [5:0] i, output logic [5:0] o);
  T x;
  if (1) begin : g
    assign x = i;
  end
  assign o = x;
endmodule
