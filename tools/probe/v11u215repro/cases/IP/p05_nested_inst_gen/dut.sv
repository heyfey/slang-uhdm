// § impPatCopyFirstListingUnparented215 — the importing module instantiated inside a for-generate and an if-generate, two levels down
package hp;
  typedef struct packed { logic a; logic b; logic [3:0] c; } e_t;
  parameter e_t EA = '{ a: 1'b0, b: 1'b1, c: 4'd3 };
  parameter e_t EB = '{ a: 1'b1, b: 1'b0, c: 4'd9 };
endpackage
package ip;
  import hp::*;
  parameter logic [1:0] LOC = 2'b01;
endpackage
module leaf import hp::*; import ip::*; (output logic [5:0] o);
  assign o = EB;
endmodule
module mid (output logic [5:0] o);
  if (1) begin : g
    leaf l(.o(o));
  end
endmodule
module dut (output logic [11:0] o);
  for (genvar i = 0; i < 2; i++) begin : gg
    mid u(.o(o[i*6 +: 6]));
  end
endmodule
