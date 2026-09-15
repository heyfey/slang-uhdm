module dut;
  localparam int W = 8;
  localparam type it_t = union packed {
    logic [W+3:0] a;
    logic [11:0]  b;
  };
  localparam it_t I = 12'd5;
  logic [$bits(it_t)-1:0] z;
  initial z = I;
endmodule
