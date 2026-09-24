package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
endpackage
module sub #(parameter q2::row_t P = '0) (output logic [5:0] o);
  assign o = P;
endmodule
module dut (output logic [5:0] o);
  sub #(.P(6'h2a)) u (.o(o));
endmodule
