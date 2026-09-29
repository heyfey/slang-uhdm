// § impPatCopyFirstListingUnparented215 — a nested packed struct pattern, a default pattern and a replication pattern, imported through two packages into a module inside a generate loop
package hp;
  typedef struct packed { logic [1:0] x; logic y; } in_t;
  typedef struct packed { in_t i; logic [3:0] z; } s_t;
  parameter s_t PN = '{ i: '{ x: 2'd1, y: 1'b1 }, z: 4'd7 };
  parameter s_t PD = '{ default: '0 };
  parameter in_t PR = '{ x: {2{1'b1}}, y: 1'b0 };
endpackage
package ip;
  import hp::*;
  export hp::*;
endpackage
module leaf import ip::*; import hp::*; (output logic [6:0] o, output logic [2:0] r);
  assign o = PN ^ PD;
  assign r = PR;
endmodule
module dut (output logic [6:0] o [2], output logic [2:0] r [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    leaf u (.o(o[i]), .r(r[i]));
  end
endmodule
