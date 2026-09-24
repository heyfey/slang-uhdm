// § ovrMultiDimConstUnparented131
module sub #(parameter logic [1:0][3:0] P = '0) (output logic [7:0] o);
  if (1) begin : g
    assign o = P;
  end
endmodule
module top (output logic [7:0] o);
  sub #(.P(8'h5a)) u(.o(o));
endmodule
