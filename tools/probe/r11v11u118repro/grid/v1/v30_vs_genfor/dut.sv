package cfgp;
  localparam logic [31:0] K = 32'hCAFE_F00D;
  parameter logic [15:0] PK2 = 16'h1234;
  localparam int N = 8;
  localparam logic [3:0][7:0] A2 = 32'h89AB_CDEF;
  localparam logic [1:0][1:0][3:0] A3 = 16'hBEEF;
  localparam logic [7:0] C = {4'hA, 4'h5};
endpackage
module top (output logic [15:0] o);
  for (genvar i = 0; i < 4; i++) begin : g
    assign o[i*4 +: 4] = cfgp::A2[i][3:0];
  end
endmodule
