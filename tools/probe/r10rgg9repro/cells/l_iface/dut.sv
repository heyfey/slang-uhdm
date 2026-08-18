interface bus_t;
  logic [7:0] d;
  modport slave (output d);
endinterface
module m #(
  parameter bit P = 0
)(bus_t.slave bif);
  logic sig;
  assign bif.d = (P) ? {2{sig}} : '0;
endmodule
module top;
  bus_t bi();
  m #(.P(0)) u_a(.bif(bi));
endmodule
