// § sysSignNameSpanSyntax172
module dut #(parameter int W = 8) (input logic [7:0] a, output logic [7:0] o);
  logic [$signed(W)-1:0] n;
  if (W > 4) begin : g
    logic [$unsigned(W)-1:$signed(0)] m;
    assign m = a;
    assign n = m;
  end
  assign o = n;
endmodule
