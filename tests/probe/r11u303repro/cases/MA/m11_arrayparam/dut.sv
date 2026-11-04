// § modArrBoundSelUnstored303
module subq (output logic z); assign z = 1'b1; endmodule
module top(output logic o);
  m_ia u_ia (.o(o));
endmodule
module m_ia (output logic o);
  localparam int A [2] = '{1, 0};
  logic [1:0] zz;
  subq u_e [A[0]:0] ();
  assign o = zz[0];
endmodule
