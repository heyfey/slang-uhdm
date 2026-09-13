// LAW 1's INTERFACE analogue: the gate's DefinitionKind::Module test should
// keep this out.
interface intf(input logic [31:0] a);
  logic [31:0] arr[2];
  if (1) begin : gb
    assign arr = '{a, a};
  end
endinterface
module top(input logic [31:0] a, output logic [31:0] o);
  intf u_i(.a(a));
  assign o = u_i.arr[0];
endmodule
