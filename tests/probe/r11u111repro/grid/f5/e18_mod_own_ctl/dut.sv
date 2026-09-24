package p0;
  typedef enum logic [3:0] { A = 4'h3, B = 4'h7 } e_t;
endpackage
module dut (input logic [7:0] i, output logic o);
  import p0::*;
  localparam logic [1:0] C0 = 2'b01;
  localparam logic [7:0] X = { 2'h0, C0, {A} };
  assign o = (i == X);
endmodule
