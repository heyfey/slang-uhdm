// § rqParamOpBoundAtCall216v (with § genScopeRangeQueryFold216) — parameter operands with arithmetic bounds W*2-1:W and W+3:W-1 read at depth 2 (gen-if in gen-for) and a localparam with a qualified bound
package pk;
  parameter int PW = 3;
endpackage
module dut #(parameter int W = 2, parameter logic [W*2-1:W] P = 0) (output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  localparam logic [W+3:W-1] LQ = 0;
  localparam logic [pk::PW+1:1] LR = 0;
  for (genvar i = 0; i < 2; i++) begin : a
    if (i == 0) begin : b
      assign o1 = $high(P);
      assign o2 = $low(LQ);
      assign o3 = $left(LR);
    end
  end
endmodule
