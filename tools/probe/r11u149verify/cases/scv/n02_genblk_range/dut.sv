// § sysArgUnaryConstSelToken140v
module dut(input logic [3:0] a, input logic [7:0] x, output logic [3:0] y);
  if (1) begin : g
    assign y = x[$bits(~a)-1:0];
  end
endmodule
