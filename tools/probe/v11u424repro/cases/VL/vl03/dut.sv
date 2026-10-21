// § defGenLpSelIdxThroughBase424
module top #(parameter logic [7:0] P = 8'hA5) (output logic o);
  if (1) begin : g
    localparam W = 3;
    localparam A = P[W-1];
    assign o = A;
  end
endmodule
