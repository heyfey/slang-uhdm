module top (input logic [31:0] a, input logic [4:0] s,
            output logic [31:0] o2, output logic [31:0] o3);
  if (1) begin
    logic [31:0] uv;
    assign uv = a & 32'hff;
  end
  assign o2 = a;
endmodule
