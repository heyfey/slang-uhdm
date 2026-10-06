// § patLitFormFileAtRef256 (the pattern inside a generate scope)
module top(output logic [19:0] o);
  if (1) begin : g
    localparam dm::hartinfo_t H = '{zero1: '0, datasize: dm::DataCount, dataaddr: dm::DataAddr};
    assign o = H;
  end
endmodule
