// DEFPAT: a control: a module's own default-fill array keeps one constant.
module sub #(parameter int A[2] = '{default: 3}) (output int o);
  assign o = A[0];
endmodule
module top(output int o);
  sub u(.o(o));
endmodule
