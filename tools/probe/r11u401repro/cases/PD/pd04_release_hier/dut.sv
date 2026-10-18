// § deassignReleaseObj401
module sub(output logic q);
  initial q = 0;
endmodule
module top();
  wire q;
  sub u(.q(q));
  initial begin
    force u.q = 1;
    #1 release u.q;
  end
endmodule
