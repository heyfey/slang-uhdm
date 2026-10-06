// § patLitFormFileAtRef256 (a pattern given as an instance parameter override)
module m #(parameter dm::hartinfo_t H = '0)(output logic [19:0] o); assign o = H; endmodule
module top(output logic [19:0] o);
  m #(.H('{zero1: '0, datasize: dm::DataCount, dataaddr: dm::DataAddr})) u(.o(o));
endmodule
