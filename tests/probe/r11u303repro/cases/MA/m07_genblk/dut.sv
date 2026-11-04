// § modArrBoundSelUnstored303
module subq (output logic z); assign z = 1'b1; endmodule
module top(output logic o);
  m_ia u_ia (.o(o));
endmodule
module m_ia (output logic o);
  localparam logic [4-1:0] X = {4{1'b1}};
  logic [1:0] zz;
  if (1) begin : g
    subq u_e [X[0]:0] ();
  end
  assign o = zz[0];
endmodule
