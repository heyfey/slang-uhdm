// § defGenCaCommaListSpan283
interface ifc (input logic [3:0] x);
  logic [3:0] a, b;
  if (1) begin : g
    assign a = x, b = ~x;
  end
endinterface
module dut (input logic [3:0] x, output logic [3:0] o);
  ifc u (.x(x));
  assign o = u.a;
endmodule
