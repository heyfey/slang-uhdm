// § bodyTypeParamChainBorrow278
module sub #(parameter int W = 2) ( input logic [7:0] i, output logic o );
  localparam type a_t = logic [W-1:0];
  localparam type b_t = a_t;
  b_t x;
  assign x = i;
  assign o = ^x;
endmodule
module dut ( input logic [7:0] i, output logic o1, output logic o2 );
  sub a(i, o1);
  sub #(5) b(i, o2);
endmodule
