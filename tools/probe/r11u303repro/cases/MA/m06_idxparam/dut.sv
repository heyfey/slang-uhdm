// § modArrBoundSelUnstored303
module subq (output logic z); assign z = 1'b1; endmodule
module top(output logic o);
  m_ia u_ia (.o(o));
endmodule
module m_ia #(parameter int P = 1) (output logic o);
  localparam logic [4-1:0] X = {2{2'b01}};
  logic [1:0] zz;
  subq u_e [X[P]:0] ();
  assign o = zz[0];
endmodule
