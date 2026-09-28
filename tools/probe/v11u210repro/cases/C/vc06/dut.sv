// § caseItemImpWildParamScopeName210 — vc06 (v11u210 break probe): a TASK declared in a generate if-block and an always_comb in a for-generate read the wildcard-valued imported parameter in casez items
package tp;
  parameter logic [3:0] W2 = { 2'b1?, 2'b1z };
endpackage
module dut import tp::*; (input logic [3:0] a, output int q, output int r [2]);
  if (1) begin : gb
    task automatic t(input logic [3:0] i, output int x);
      casez (i)
        W2: x = 5;
        default: x = 6;
      endcase
    endtask
    always_comb t(a, q);
  end
  for (genvar k = 0; k < 2; k++) begin : gf
    always_comb begin
      casez (a)
        W2: r[k] = k;
        default: r[k] = 7;
      endcase
    end
  end
endmodule
