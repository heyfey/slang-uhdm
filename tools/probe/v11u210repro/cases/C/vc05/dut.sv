// § caseItemImpWildParamScopeName210 — vc05 (v11u210 break probe): explicit single-name imports in the module body, an always_ff named block and a NESTED case whose inner items read the wildcard-valued parameter, beside a plain-valued one
package tp;
  parameter logic [3:0] W2 = { 2'b??, 2'b11 };
  parameter logic [3:0] N1 = 4'b0011;
endpackage
module dut(input logic clk, input logic [3:0] a, output int o, output int p);
  import tp::W2;
  import tp::N1;
  always_ff @(posedge clk) begin : blk
    casez (a)
      W2: o <= 1;
      N1: o <= 2;
      default: o <= 0;
    endcase
  end
  always_comb begin
    casez (a[3])
      1'b1: casez (a)
              N1, W2: p = 3;
              default: p = 4;
            endcase
      default: p = 0;
    endcase
  end
endmodule
