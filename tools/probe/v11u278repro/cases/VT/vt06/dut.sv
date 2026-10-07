// § bodyTypeParamChainBorrow278
module dut ( input logic [2:0] i, output logic o );
  localparam type a_t = enum logic [1:0] {A, B, C};
  localparam type b_t = a_t;
  b_t x;
  assign x = b_t'(i[1:0]);
  assign o = (x == B);
endmodule
