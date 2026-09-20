package q;
  typedef logic [7:0] v8_t;
endpackage
module c6 import q::*; (output logic [7:0] o);
  localparam v8_t A = v8_t'{default: 1'b1};
  assign o = A;
endmodule
