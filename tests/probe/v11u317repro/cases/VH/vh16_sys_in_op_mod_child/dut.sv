// § defGenSysInOpLeaf317
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] ck, input logic s, input logic a, output logic o);
  for (genvar i = 0; i < 1; i++) begin : g
    child c (.d($signed(ck[s]) ^ a), .q(o));
  end
endmodule
