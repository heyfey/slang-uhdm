// § caseItemImpWildParamScopeName210 — r11u217 c03: the wildcard concatenation parameter reached through an EXPLICIT single-name import in a task and in an interface function, a parenthesized item and a two-item list `I_Q, I_R:`
package tp;
  parameter logic [1:0] OP = 2'b01;
  parameter logic [7:0] I_Q = { 3'b110, 3'h?, {OP} };
  parameter logic [7:0] I_R = { 3'b111, 3'h?, {OP} };
endpackage
interface ifc;
  import tp::I_Q;
  logic [7:0] v;
  function automatic int f(logic [7:0] i);
    casez (i)
      I_Q: return 1;
      default: return 0;
    endcase
  endfunction
endinterface
module dut (input logic [7:0] insn, output int o, output int p);
  import tp::I_Q;
  import tp::I_R;
  ifc i();
  assign i.v = insn;
  int r;
  task automatic t(input logic [7:0] x);
    casez (x)
      (I_Q): r = 5;
      I_Q, I_R: r = 6;
      default: r = 0;
    endcase
  endtask
  always_comb begin
    t(insn);
    o = r;
  end
  assign p = i.f(i.v);
endmodule
