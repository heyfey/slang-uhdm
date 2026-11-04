// § defGenNestSelEscBase317v
module child (input logic d, output logic q);
  assign q = d;
endmodule
module top (input logic [3:0] \ck$x , input logic [1:0] k, input logic a, output logic o);
  if (1) begin : g
    child c (.d(\ck$x [k[1]] ^ a), .q(o));
  end
endmodule
