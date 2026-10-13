// § defGenModArraySizeRange309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [3:0] o);
  if (1) begin : g
    ifc finst ();
    child a3 [2][2] (.p(finst), .o(o));
  end
endmodule
