// § nestedPosInstUdp307
module outer (input logic a, b, output logic y);
  module inner (o, i, j);
    output o;
    input i, j;
    assign o = i ^ j;
  endmodule
  inner u_in (y, a, b);
endmodule
module dut (input logic a, b, output logic y);
  outer u1 (a, b, y);
endmodule
