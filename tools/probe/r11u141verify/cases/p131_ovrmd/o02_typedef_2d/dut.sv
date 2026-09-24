// § ovrMultiDimConstUnparented131
// case o02: a 2-D packed parameter typed by a local typedef, overridden
module sub #(parameter int W = 4) (output logic [2*W-1:0] o);
  typedef logic [1:0][W-1:0] t;
  localparam t L = '1;
  assign o = L;
endmodule
module top(output logic [7:0] o);
  sub #(.W(4)) u(.o(o));
endmodule
