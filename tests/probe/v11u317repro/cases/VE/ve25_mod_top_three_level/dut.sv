// § nestSelChainName317v
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] ck, input logic [1:0] k, input logic [1:0] j, output logic o);
  child c (.d(ck[k[j[0]]]), .q(o));
endmodule
