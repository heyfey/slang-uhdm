module sub (input logic [31:0] a);
  logic [31:0] iv;
  assign iv = a;
endmodule
module top (input logic [31:0] a, input logic [4:0] s,
            output logic [31:0] o2, output logic [31:0] o3);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = u1.iv;
    assign o2 = lv;
  end
  sub u1 (.a(a));
endmodule
