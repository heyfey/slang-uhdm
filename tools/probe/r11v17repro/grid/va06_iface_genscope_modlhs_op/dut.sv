// INTERFACE gen scope: bindVariable has NO uhdminterface_inst case, so it
// recurses PAST the interface and finds nothing -> no clone -> the Rhs keeps
// its definition bindings. LAW 2's gate has no interface test.
interface intf(input logic [31:0] a);
  logic [31:0] mv;
  logic [31:0] netd;
  assign netd = a;
  if (1) begin : gb
    logic [31:0] src;
    assign src = a;
    assign mv = src | netd;
  end
endinterface
module top(input logic [31:0] a, output logic [31:0] o);
  intf u_i(.a(a));
  assign o = u_i.mv;
endmodule
