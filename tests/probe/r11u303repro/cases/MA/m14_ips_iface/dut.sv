// § modArrBoundIpsWholeSpan303
interface sif; logic v; endinterface
module top;
  m_ia u_ia ();
endmodule
module m_ia;
  localparam logic [4-1:0] X = {2{2'b01}};
  sif s [X[1+:2]:0] ();
endmodule
