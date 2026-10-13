// § nestSelChainName317v
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] ck, input logic [2:0] k, input logic s, input logic a, output logic o);
  for (genvar i = 0; i < 1; i++) begin : g
    child c (.d(ck[k[s+i]] & a), .q(o));
  end
endmodule
