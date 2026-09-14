module top (input logic [31:0] a, input logic [4:0] s,
            output logic [31:0] o2, output logic [31:0] o3);
  logic [31:0] mv;
  assign o2 = mv;
  if (1) begin : gb
    assign mv = a & 32'hff;
  end
endmodule
