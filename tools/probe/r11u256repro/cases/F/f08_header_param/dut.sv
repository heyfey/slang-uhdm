// § patLitFormFileAtRef256 (a header parameter default and an override)
module m #(parameter dm::hartinfo_t H = '{zero1: '0, datasize: dm::DataCount, dataaddr: dm::DataAddr}) (output logic [19:0] o);
  assign o = H;
endmodule
module top(output logic [19:0] o, output logic [19:0] p);
  m u (.o(o));
  m #(.H('{zero1: 4'h3, datasize: dm::DataCount, dataaddr: 12'h7})) v (.o(p));
endmodule
