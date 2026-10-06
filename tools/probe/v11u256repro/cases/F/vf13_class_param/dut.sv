// § patLitFormFileAtRef256 (the pattern a class localparam)
class K; localparam dm::hartinfo_t H = '{zero1: '0, datasize: dm::DataCount, dataaddr: dm::DataAddr}; endclass
module top(output logic [19:0] o);
  assign o = K::H;
endmodule
