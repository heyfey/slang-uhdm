// § ndaSysCallNetTs212 — r11u217 n04: net declarations with whole-initializer calls $bits, $clog2 and a signing cast, on a typedef net, a scalar net and an INTERFACE net (module-only law: control)
typedef logic [7:0] b_t;
interface ifc (input logic [7:0] x);
  wire [7:0] iw = $unsigned(x);
endinterface
module dut(input logic [7:0] x, output logic [7:0] o, output logic p, output logic [7:0] q);
  wire b_t t = unsigned'(x);
  wire s = $signed(x[0]);
  wire [3:0] c = $clog2(x);
  wire [7:0] n = $bits(x);
  ifc i (.x(x));
  assign o = t ^ n ^ {4'd0, c};
  assign p = s;
  assign q = i.iw;
endmodule
