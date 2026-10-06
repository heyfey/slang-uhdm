// § patLitFormFileAtRef256 (the member value written through a macro in the module file)
`define DC dm::DataCount
module top(output logic [19:0] o);
  localparam dm::hartinfo_t H = '{zero1: '0, datasize: `DC, dataaddr: dm::DataAddr};
  assign o = H;
endmodule
