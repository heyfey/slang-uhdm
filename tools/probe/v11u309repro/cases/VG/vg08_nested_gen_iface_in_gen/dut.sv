// § ifaceTailDupGenChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : gf
    ifc gi ();
    if (1) begin : gin
      child c (.p(gi), .o(o[i]));
    end
  end
endmodule
