// § defGenModArraySizeRange309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top #(parameter int M = 0) (output logic [1:0] o);
  case (M)
    0: begin : c0
      ifc finst ();
      child a3 [2] (.p(finst), .o(o));
    end
    default: begin : cd
      assign o = '0;
    end
  endcase
endmodule
