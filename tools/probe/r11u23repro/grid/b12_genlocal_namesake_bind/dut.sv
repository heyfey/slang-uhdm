module top (input logic [31:0] a, input logic [4:0] s,
            output logic [31:0] o2, output logic [31:0] o3);
  logic [31:0] nv;
  assign o3 = nv;
  if (1) begin : gb
    logic [31:0] nv;
    assign nv = a & 32'hff;
    assign o2 = nv;
  end
endmodule
