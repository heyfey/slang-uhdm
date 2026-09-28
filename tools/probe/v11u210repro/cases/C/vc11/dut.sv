// § caseItemImpWildParamScopeName210 — vc11 (v11u210 break probe): the wildcard-valued parameter reaches the module through ANOTHER package that imports and exports it
package tp;
  parameter logic [3:0] W2 = { 2'b??, 2'b11 };
endpackage
package bp;
  import tp::*;
  export tp::*;
  parameter logic [3:0] USE = W2;
endpackage
module dut import bp::*; (input logic [3:0] a, output logic [1:0] o);
  always_comb begin
    casez (a)
      W2: o = 2'd1;
      default: o = 2'd0;
    endcase
  end
endmodule
