// r10v104 vb4 -- MINIMAL: an INSTANCE ARRAY's range reads the parameter.
module subq104 #(parameter P = 0) (output logic z); assign z = |P; endmodule
module vb4_instarr(output logic o);
  m_ia u_ia (.o(o));
endmodule
module m_ia (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] zz;
  subq104 #(.P(2)) u_e [X[0]:0] (.z(zz));
  assign o = zz[0];
endmodule
