package cfgp;
  localparam logic [31:0] K = 32'hCAFE_F00D;
  parameter logic [15:0] PK2 = 16'h1234;
  localparam int N = 8;
  localparam logic [3:0][7:0] A2 = 32'h89AB_CDEF;
  localparam logic [1:0][1:0][3:0] A3 = 16'hBEEF;
  localparam logic [7:0] C = {4'hA, 4'h5};
endpackage
module sub #(parameter logic [7:0] P = 8'h0) (output logic [7:0] o);
  assign o = P;
endmodule
module top (output logic [7:0] o);
  sub #(.P(cfgp::K[8 +: 8])) u (.o(o));
endmodule
