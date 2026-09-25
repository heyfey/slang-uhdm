// § genLpUintCaRhsOwnCopy148
module top(output logic o);
  generate if (1) begin : g
    localparam [0:0] L = 1;
    assign o = L;
  end endgenerate
endmodule
