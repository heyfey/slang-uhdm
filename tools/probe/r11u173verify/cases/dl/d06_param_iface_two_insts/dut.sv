// § caDelayParamElabFresh164 § caDelayFirstOnly164 — a parameter delay inside an interface, two interface instances with overrides
interface d_if #(parameter D = 1);
  logic a, b, c;
  assign #D b = a, c = a;
endinterface
module top(input x, output y, output z);
  d_if #(.D(2)) i0();
  d_if #(.D(5)) i1();
  assign i0.a = x;
  assign i1.a = x;
  assign y = i0.b;
  assign z = i1.c;
endmodule
