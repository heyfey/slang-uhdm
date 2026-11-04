// § defGenLhsHpBaseAnchor144
interface bus_if; logic d; logic v; modport mp(output d, v); endinterface
module top(output logic o);
  bus_if b[2]();
  for (genvar i = 0; i < 2; i++) begin: g
    assign b[i].d = 1'b1;
    assign b[i].v = b[i].d;
  end
  assign o = b[0].v;
endmodule
