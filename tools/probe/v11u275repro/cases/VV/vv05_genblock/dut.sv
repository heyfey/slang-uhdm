// § tpTypedVarInitNameSpan275 — a type-parameter variable with an initializer inside a generate block
module dut #(parameter type T = logic [3:0]) (output logic [3:0] o);
  if (1) begin : g
    T x = 4'h3;
    assign o = x;
  end
endmodule
