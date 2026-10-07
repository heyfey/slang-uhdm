// § bodyTypeParamChainBorrow278
module dut ( output logic o );
  localparam type a_t = int;
  localparam type b_t = a_t;
  b_t x;
  assign x = 3;
  assign o = x[0];
endmodule
