// § patLitFormFileAtRef256 (a package pattern reading another file package)
package uses;
  localparam dm::hartinfo_t H = '{zero1: '0, datasize: dm::DataCount, dataaddr: dm::DataAddr};
endpackage
module top(output logic [19:0] o);
  assign o = uses::H;
endmodule
