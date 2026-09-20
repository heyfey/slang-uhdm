package q;
  typedef union packed { logic [7:0] w; logic [7:0] v; } un_t;
endpackage
module c4 import q::*; (output logic [7:0] o);
  localparam un_t A = un_t'{w: 8'd7, v: 8'd7};
  assign o = A;
endmodule
