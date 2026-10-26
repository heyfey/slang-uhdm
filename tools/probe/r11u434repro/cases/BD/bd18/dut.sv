// § genBodyDefSysArgCallTree434
module top (output [31:0] y);
  if (1) begin: g
    logic [4:0] z;
    assign y = $clog2($bits(z)) + 1;
  end
endmodule
