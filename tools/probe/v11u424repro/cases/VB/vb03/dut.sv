// § defGenLpSysArgBitSelAtIndex424
module top #(parameter int P [4] = '{1,2,3,4}) (output int o);
  if (1) begin : g
    localparam int A = $clog2(P[2]) + $bits(P[1]);
    assign o = A;
  end
endmodule
