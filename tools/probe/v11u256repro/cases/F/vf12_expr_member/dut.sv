// § patLitFormFileAtRef256 (a member written as an expression of a package value (control))
module top(output logic [19:0] o);
  localparam dm::hartinfo_t H = '{zero1: '0, datasize: dm::DataCount + 4'h1, dataaddr: dm::DataAddr};
  assign o = H;
endmodule
