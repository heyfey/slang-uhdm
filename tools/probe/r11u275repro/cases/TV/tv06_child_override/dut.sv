// § tpTypedVarInitNameSpan275 — an overridden child type parameter with an initializer
module child #(parameter type T = logic) (output logic [7:0] o);
  T x = '1;
  assign o = x;
endmodule
module dut (output logic [7:0] o);
  child #(.T(logic [7:0])) u (.o(o));
endmodule
