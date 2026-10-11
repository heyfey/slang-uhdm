// § caHierSelBoundName282
interface ifc; logic [7:0] addr; endinterface
module top #(parameter int BW = 2) (ifc i, output logic y);
  assign y = |i.addr[BW +: 1];
endmodule
module wrap(input logic [7:0] a, output logic y); ifc ii(); assign ii.addr = a; top u(.i(ii), .y(y)); endmodule
