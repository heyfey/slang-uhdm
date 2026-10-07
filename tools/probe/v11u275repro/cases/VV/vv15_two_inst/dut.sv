// § tpTypedVarInitNameSpan275 — two instances with different overrides
module child #(parameter type T = logic [3:0]) (output logic [7:0] o);
  T x = '1;
  assign o = 8'(x);
endmodule
module dut (output logic [7:0] o, output logic [7:0] p);
  child #(.T(logic [1:0])) a (.o(o));
  child #(.T(logic [5:0])) b (.o(p));
endmodule
