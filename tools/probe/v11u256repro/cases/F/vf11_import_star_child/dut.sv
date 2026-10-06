// § patLitFormFileAtRef256 (an imported pattern member in a child instance at depth 2)
module c import dm::*; (output logic [19:0] o);
  localparam hartinfo_t H = '{zero1: '0, datasize: DataCount, dataaddr: DataAddr};
  assign o = H;
endmodule
module mid(output logic [19:0] o); c u2(.o(o)); endmodule
module top(output logic [19:0] o); mid u1(.o(o)); endmodule
