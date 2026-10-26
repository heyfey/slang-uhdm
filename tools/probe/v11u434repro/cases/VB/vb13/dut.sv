// § genBodyDefSysArgCallTree434
module top #(parameter W = 2) (output logic [31:0] y, output logic [31:0] z);
  logic [4:0] x [3];
  if (W > 1) begin : g
    assign y = $clog2($size(x));
    assign z = $signed($bits(x));
  end
endmodule
