// r10v104 vb3 -- MINIMAL: a TYPEDEF's declared RANGE reads the parameter.
module vb3_tdefrange(output logic o);
  m_td u_td (.o(o));
endmodule
module m_td (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  typedef logic [X[0]:0] t8;
  t8 w8;
  assign w8 = '0;
  assign o = w8[0];
endmodule
