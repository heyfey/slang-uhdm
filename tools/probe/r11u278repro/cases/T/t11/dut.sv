// § bodyTypeParamChainBorrow278
module dut ( input logic [2:0] i, output logic o );
  if (1) begin : g
    localparam type a_t = logic [2:0];
    localparam type b_t = a_t;
    b_t x;
    assign x = i;
  end
  assign o = ^g.x;
endmodule
