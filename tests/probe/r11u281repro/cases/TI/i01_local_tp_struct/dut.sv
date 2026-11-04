// § ifaceInstTypeParamSharesDef281
interface ifc;
  localparam type it_t = struct packed { logic [7:0] x; logic [7:0] y; };
  localparam it_t I = '{x: 8'd1, y: 8'd2};
  logic [7:0] q;
  assign q = I.x;
endinterface
module dut (output logic [7:0] b_o);
  ifc u();
  assign b_o = u.q;
endmodule
