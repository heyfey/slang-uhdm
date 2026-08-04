module mux #(parameter int ENTRIES = 2)(output logic o);
  assign o = ENTRIES[0];
endmodule

module reg_common #(
  parameter int DATA_WIDTH = 32,
  parameter int BUS_WIDTH  = 32,
  parameter int REGISTERS  = 1
)(output logic a, output logic b, output logic c, output logic d);
  localparam int WORDS = DATA_WIDTH / BUS_WIDTH;
  localparam int PLAIN = 3;
  mux #(.ENTRIES(WORDS))     m1(a);
  mux #(.ENTRIES(REGISTERS)) m2(b);
  mux #(.ENTRIES(2))         m3(c);
  mux #(.ENTRIES(PLAIN))     m4(d);
endmodule

module top(output logic a, output logic b, output logic c, output logic d);
  reg_common #(.DATA_WIDTH(64)) u(a, b, c, d);
endmodule
