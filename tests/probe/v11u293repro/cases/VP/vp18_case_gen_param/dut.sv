// § portViewNdaNetCellParent293
// A case-generate block holding the module, with a parameter-sized initializer.
interface ifc #(parameter int W = 8) ();
  wire [W-1:0] w = W;
  modport mp (input w);
endinterface
module sub (ifc.mp p, output logic [7:0] o);
  assign o = p.w;
endmodule
module top #(parameter int K = 1) (output logic [7:0] o);
  ifc u_if ();
  case (K)
    1: begin : c1
      sub u_s (.p(u_if), .o(o));
    end
    default: begin : cd
      assign o = '0;
    end
  endcase
endmodule
