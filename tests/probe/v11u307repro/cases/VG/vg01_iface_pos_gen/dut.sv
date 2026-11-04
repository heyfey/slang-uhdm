// § defGenUdpFormNoStmt307
interface ifc (input logic c, input logic r); logic w; endinterface
module outer (input logic a, b, output logic y);
  if (1) begin : g
    ifc u_if (a, b);
    assign y = u_if.w;
  end
endmodule
module dut (input logic a, b, output logic y);
  outer u1 (.a(a), .b(b), .y(y));
endmodule
