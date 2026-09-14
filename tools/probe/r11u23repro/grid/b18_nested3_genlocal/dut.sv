module top (input logic [31:0] a, input logic [4:0] s,
            output logic [31:0] o2, output logic [31:0] o3);
  if (1) begin : g1
    if (1) begin : g2
      if (1) begin : g3
        logic [31:0] nv;
        assign nv = a & 32'hff;
      end
    end
  end
  assign o2 = a;
endmodule
