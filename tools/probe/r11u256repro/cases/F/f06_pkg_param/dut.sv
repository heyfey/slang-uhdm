// § patLitFormFileAtRef256 (the pattern itself a package parameter in a second package (another file than its members))
package p2;
  localparam dm::hartinfo_t H2 = '{zero1: '0, datasize: dm::DataCount, dataaddr: dm::DataAddr};
endpackage
module top(output logic [19:0] o);
  assign o = p2::H2;
endmodule
