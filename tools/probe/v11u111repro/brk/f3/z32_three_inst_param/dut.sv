package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module sub #(parameter q2::row_t P = '0) (output logic [5:0] o);
  assign o = P;
endmodule
module dut (output logic [17:0] o);
  sub #(.P(6'h01)) a (.o(o[5:0]));
  sub #(.P(6'h02)) b (.o(o[11:6]));
  sub c (.o(o[17:12]));
endmodule
