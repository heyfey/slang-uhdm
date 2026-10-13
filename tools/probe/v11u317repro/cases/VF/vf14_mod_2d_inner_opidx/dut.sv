// § nestSelChainName317v
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [1:0][1:0] m, input logic [2:0] k, input logic s, input logic a, output logic o);
  child c (.d(m[k[s+1]][0] & a), .q(o));
endmodule
