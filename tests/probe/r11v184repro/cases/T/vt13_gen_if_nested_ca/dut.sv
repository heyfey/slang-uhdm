// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: the whole-signal continuous assignment inside an if-generate nested in a named generate block, writing a module-level T signal
module sub #(parameter type T = logic, parameter bit P = 1) (input T si, output logic [1:0] o);
  T r;
  if (P) begin : ga
    if (P) begin : gb
      assign r = si;
    end
  end
  always_comb o = r;
endmodule
module top(output logic [1:0] c);
  typedef enum logic [1:0] {I0, I1} ie_t;
  ie_t p;
  sub #(.T(ie_t)) v (.si(p), .o(c));
endmodule
