// § modArrBoundSelUnstored303
module subq (output logic z); assign z = 1'b1; endmodule
module m_ia #(parameter logic [7:0] X = 8'd5) (output logic o);
  subq u_e [X[2:1]:0] ();
  assign o = 1'b0;
endmodule
module top(output logic o1, o2);
  m_ia u1 (.o(o1));
  m_ia #(.X(8'd3)) u2 (.o(o2));
endmodule
