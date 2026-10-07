// § pkgElabUnaryFoldOpSpan274
package pk;
  parameter int A = -3;
endpackage
module kid #(parameter int P = pk::A) (output int o); assign o = P; endmodule
module dut(output int o, output int o2);
  kid k0 (.o(o));
  kid #(.P(-pk::A)) k1 (.o(o2));
endmodule
