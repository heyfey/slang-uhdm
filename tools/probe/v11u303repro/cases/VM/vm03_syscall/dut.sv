// § modArrBoundSelUnstored303
module subq (output logic z); assign z = 1'b1; endmodule
module top(output logic o);
  m_ia u_ia (.o(o));
endmodule
module m_ia (output logic o);
  localparam logic [8-1:0] X = 8'b0000_0101;
  localparam int Y = 2;
  subq u_e [$clog2(X[3:0]):0] ();
  assign o = 1'b0;
endmodule
