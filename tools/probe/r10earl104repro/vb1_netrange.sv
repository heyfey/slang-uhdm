// r10v104 vb1 -- MINIMAL: a net's declared RANGE reads the parameter.
module vb1_netrange(output logic o);
  m_nr u_nr (.o(o));
endmodule
module m_nr (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [X[0]:0] w5;
  assign w5 = '0;
  assign o = w5[0];
endmodule
