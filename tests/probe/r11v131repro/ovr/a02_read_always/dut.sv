// § ovrMultiDimConstUnparented131
module sub #(parameter logic [3:0][5:0] P = '0) (output logic [23:0] o);
  always_comb o = P;
endmodule
module top (output logic [23:0] o);
  sub #(.P(24'b1)) u(.o(o));
endmodule
