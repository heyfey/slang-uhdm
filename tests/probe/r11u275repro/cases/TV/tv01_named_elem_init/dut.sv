// § tpTypedVarInitNameSpan275 — a named-element array type parameter with an initializer
module dut #(parameter type id_t = logic [1:0], localparam type rt_t = id_t [3:0]) (output logic [7:0] o);
  rt_t x = 8'h5a;
  assign o = x;
endmodule
