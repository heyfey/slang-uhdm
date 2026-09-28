// § defGenTargetIpsDefName205: a parameter-based indexed part select of an interface member as an if-generate target
interface bif;
  logic [7:0] d;
endinterface
module dut #(parameter int P = 4) (input logic [3:0] x, output logic [7:0] o);
  bif b();
  if (P > 0) begin : g
    assign b.d[P+:4] = x;
  end
  assign b.d[3:0] = '0;
  assign o = b.d;
endmodule
