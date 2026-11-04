// § genvarParamFile125
module top(input logic [3:0] a, output logic [3:0] o);
  if (1) begin : c
    for (genvar i = 0; i < 2; i++) begin : g
      if (i == 0) begin : z
        assign o[i] = a[i];
      end else begin : nz
        assign o[i] = ~a[i];
      end
    end
  end
  assign o[3:2] = a[3:2];
endmodule
