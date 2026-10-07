// § tpTypedVarInitNameSpan275 — anonymous packed struct type parameter, initializer
module dut #(parameter type T = struct packed { logic [1:0] a; logic [1:0] b; }) (output logic [3:0] o);
  T x = 4'h9;
  assign o = x;
endmodule
