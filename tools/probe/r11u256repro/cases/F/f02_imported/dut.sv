// § patLitFormFileAtRef256 (the same members read through a wildcard import)
module top import dm::*; (output logic [19:0] o);
  localparam hartinfo_t H = '{zero1: '0, datasize: DataCount, dataaddr: DataAddr};
  assign o = H;
endmodule
