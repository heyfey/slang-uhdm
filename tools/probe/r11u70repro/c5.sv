package q;
  typedef logic [3:0] v4_t [0:1];
endpackage
module c5 import q::*; (output logic [3:0] o);
  localparam v4_t A = v4_t'{4'd1, 4'd2};
  assign o = A[0];
endmodule
