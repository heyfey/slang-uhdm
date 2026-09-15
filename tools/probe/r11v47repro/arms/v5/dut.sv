module dut;
  localparam type it_t = enum logic [1:0] { EA, EB, EC };
  localparam it_t I = EB;
  logic [1:0] z;
  initial z = I;
endmodule
