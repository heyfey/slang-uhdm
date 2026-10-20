// § paramInitSysArgBitSelAtIndex421
module c #(parameter bit [3:0][3:0] P = 0) (output logic [3:0] o);
  localparam W = $clog2(P[2]);
  assign o = W;
endmodule
module top(output logic [3:0] o1, o2); c #(.P('h4321)) u(o1); c v(o2); endmodule
