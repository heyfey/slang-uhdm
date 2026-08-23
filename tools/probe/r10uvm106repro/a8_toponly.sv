// a8: parameters declared in a module that IS a top (never instantiated) —
// the elaborated copy is the module's own, not an import copy.
module a8_top_a;
  parameter P_HEX = 'h1a;
  parameter P_BIN = 'b101;
  parameter P_OCT = 'o17;
  parameter P_DEC = 'd13;
  parameter P_SHEX = 'sh1a;
  parameter P_SBIN = 'sb101;
  parameter P_SDEC = 'sd13;
  parameter P_HEXX = 'hx;
  localparam P_LHEX = 'h2b;
  parameter int P_TINT = 'h3c;
endmodule
module a8_top_b;
  parameter Q_HEX = 'h4d;
  a8_child c0();
endmodule
module a8_child;
  parameter C_HEX = 'h5e;
  parameter C_SHEX = 'sh5;
endmodule
