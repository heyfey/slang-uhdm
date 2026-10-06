// § patLitFormFileAtRef256 (the member value from a macro defined in an include)
`include "mac.svh"
module top(output logic [19:0] o);
  localparam dm::hartinfo_t H = '{zero1: '0, datasize: `DC, dataaddr: `DA};
  assign o = H;
endmodule
