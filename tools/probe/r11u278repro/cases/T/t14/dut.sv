// § bodyTypeParamChainBorrow278
module dut ( output logic o );
  localparam type a_t = real;
  localparam type b_t = a_t;
  b_t x;
  assign x = 1.0;
  assign o = (x == 0.0);
endmodule
