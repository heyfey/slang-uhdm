// § modArrBoundSelUnstored303
module subq (output logic z); assign z = 1'b1; endmodule
module top(output logic o, p);
  m_ia #(.X(4'b0001)) u_a (.o(o));
  m_ia #(.X(4'b0011)) u_b (.o(p));
endmodule
module m_ia #(parameter logic [4-1:0] X = 4'b1111) (output logic o);
  logic [1:0] zz;
  subq u_e [X[0]:0] ();
  assign o = zz[0];
endmodule
