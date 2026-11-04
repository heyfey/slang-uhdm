// § genScopeIfaceArrayElems311
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top #(parameter bit E = 0) (output logic [1:0] o);
  if (E) begin : gy
    assign o = '0;
  end else begin : gn
    ifc farr [1:0] ();
    child c0 (.p(farr[1]), .o(o[0]));
    child c1 (.p(farr[0]), .o(o[1]));
  end
endmodule
