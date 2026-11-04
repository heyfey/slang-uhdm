// § bodyTypeParamChainBorrow278
module child #(parameter type a_t = logic [2:0]) ( input logic [5:0] i, output logic o );
  localparam type b_t = a_t;
  b_t x;
  assign x = i;
  assign o = ^x;
endmodule
module dut ( input logic [5:0] i, output logic o );
  child #(.a_t(logic [5:0])) u (.i(i), .o(o));
endmodule
