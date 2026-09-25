// § defaultFillOneConstant140
module sub #(parameter int A [2] = '{default: 1}) (output int o);
  assign o = A[0];
endmodule
module dut(output int o, output int o2);
  sub u(.o(o));
  sub #(.A('{default: 4})) v(.o(o2));
endmodule
