// § bodyTypeParamChainBorrow278
module child ( input logic [2:0] i, output logic o );
  localparam type a_t = logic [2:0];
  localparam type b_t = a_t;
  b_t x;
  assign x = i;
  assign o = ^x;
endmodule
module dut ( input logic [2:0] i, output logic o1, o2 );
  child u1 (.i(i), .o(o1));
  child u2 (.i(i), .o(o2));
endmodule
