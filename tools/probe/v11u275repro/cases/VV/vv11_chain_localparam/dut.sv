// § tpTypedVarInitNameSpan275 — a localparam type chained to a type parameter
module dut #(parameter type T = logic [3:0]) (output logic [3:0] o);
  localparam type L = T;
  L x = 4'h2;
  assign o = x;
endmodule
