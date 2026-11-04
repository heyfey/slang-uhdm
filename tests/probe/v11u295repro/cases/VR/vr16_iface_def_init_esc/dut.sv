// § rawEndLineModel295
interface ifc;
  logic \e.f ; logic [7:0] g = 8'h2;
endinterface
module top(output logic [7:0] o);
  ifc i();
  assign o = i.g;
endmodule
