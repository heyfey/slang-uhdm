// § caseItemImpWildParamScopeName210 — vc07 (v11u210 break probe): a concatenated wildcard-valued package parameter and a casex in a module imported twice at depths 1 and 2
package tp;
  parameter logic [3:0] W1 = { 2'b1?, 2'b0z };
endpackage
module leaf import tp::*; (input logic [3:0] a, output int o);
  always_comb begin
    casex (a)
      W1: o = 1;
      default: o = 0;
    endcase
  end
endmodule
module mid(input logic [3:0] a, output int o);
  leaf l(.a(a), .o(o));
endmodule
module dut(input logic [3:0] a, output int o, output int p);
  leaf l0(.a(a), .o(o));
  mid m0(.a(a), .o(p));
endmodule
