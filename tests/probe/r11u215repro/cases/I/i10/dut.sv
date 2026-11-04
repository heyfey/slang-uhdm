// § impPatCopyFirstListingUnparented215 — the module inside a for-generate of its parent, two levels down
package hp;
  typedef struct packed { logic a; logic b; logic [3:0] c; } e_t;
  parameter e_t EA = '{ a: 1'b0, b: 1'b1, c: 4'd3 };
  parameter e_t EB = '{ a: 1'b1, b: 1'b0, c: 4'd9 };
endpackage
package ip;
  import hp::*;
  parameter logic [1:0] LOC = 2'b01;
endpackage
module dut import ip::*; (output logic [1:0] o);
  assign o = LOC;
endmodule
module mid(output logic [1:0] o [2]);
  for (genvar g = 0; g < 2; g++) begin : gl
    dut u(.o(o[g]));
  end
endmodule
module top;
  logic [1:0] o [2];
  mid m(.o(o));
endmodule
