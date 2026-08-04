package rp;
  parameter logic [6:0] OFF0 = 7'h 0;
  parameter logic [6:0] OFF4 = 7'h 1c;
  parameter logic [3:0] DEC3 = 4'd 3;
endpackage

module qm (
  input  logic [6:0] a,
  output logic       hit0,
  output logic       hit4,
  output logic       hitd
);
  always_comb begin
    hit0 = (a == rp::OFF0);
    hit4 = (a == rp::OFF4);
    hitd = (a[3:0] == rp::DEC3);
  end
endmodule
