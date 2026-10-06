// § patLitFormFileAtRef256 (the member value written by a macro defined in the package file)
module top(output logic [19:0] o);
  localparam dm::hartinfo_t H = '{zero1: '0, datasize: `DC, dataaddr: dm::DataAddr};
  assign o = H;
endmodule
