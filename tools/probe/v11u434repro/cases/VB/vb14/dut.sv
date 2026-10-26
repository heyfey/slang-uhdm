// § genBodyDefSysArgCallTree434
module top #(parameter W = 2) (output logic [31:0] y);
  if (W > 1) begin : g
    assign y = $clog2($clog2(256));
  end
endmodule
