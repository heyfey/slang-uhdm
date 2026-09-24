// § ovrMultiDimConstUnparented131
module sub #(parameter logic [1:0][3:0] P = '0) (output logic [7:0] o);
  localparam logic [7:0] Q = P;
  assign o = Q;
endmodule
module top (output logic [7:0] o);
  sub #(.P(8'h3)) u(.o(o));
endmodule
