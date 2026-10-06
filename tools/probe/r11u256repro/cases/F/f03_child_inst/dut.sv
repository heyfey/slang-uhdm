// § patLitFormFileAtRef256 (the pattern in a child instance, depth 2, and a generate scope)
module m(output logic [19:0] o, output logic [19:0] p);
  localparam dm::hartinfo_t H = '{zero1: 4'h1, datasize: dm::DataCount, dataaddr: dm::DataAddr};
  assign o = H;
  if (1) begin : g
    localparam dm::hartinfo_t G = '{zero1: '0, datasize: dm::DataCount, dataaddr: 12'h1};
    assign p = G;
  end
endmodule
module top(output logic [19:0] o, output logic [19:0] p);
  m u (.o(o), .p(p));
endmodule
