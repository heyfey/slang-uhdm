// § constPathBaseAnyKind146
module child(input logic [7:0] d, output logic q);
  struct packed { logic [3:0] x; logic [3:0] y; } s;
  assign s = d;
  if ($bits(s.x) == 4) begin : g
    assign q = s.x[0];
  end
endmodule
module top(input logic [7:0] d, output logic q);
  child c(.d(d), .q(q));
endmodule
