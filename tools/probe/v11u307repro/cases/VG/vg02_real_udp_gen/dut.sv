// § defGenUdpFormNoStmt307
primitive myudp (output y, input a, input b);
  table
    0 0 : 0;
    0 1 : 1;
    1 0 : 1;
    1 1 : 0;
  endtable
endprimitive
module outer (input logic a, b, output logic y);
  if (1) begin : g
    myudp u_p (y, a, b);
  end
endmodule
module dut (input logic a, b, output logic y);
  outer u1 (.a(a), .b(b), .y(y));
endmodule
