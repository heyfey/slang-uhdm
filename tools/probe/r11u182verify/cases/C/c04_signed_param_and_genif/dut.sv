// § sysSignNameSpanSyntax172
module dut #(parameter int P = 3) (input logic [7:0] a, output logic [7:0] o);
  localparam int Q = $signed(P) + 1;
  if (($unsigned(Q) > 2)) begin : g
    assign o = a + $signed(8'(Q));
  end else begin : h
    assign o = a;
  end
endmodule
