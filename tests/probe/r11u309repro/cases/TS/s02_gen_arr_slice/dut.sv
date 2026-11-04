// § ifaceArrSliceElemName309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic [1:0] o);
  ifc arr [2] ();
  if (1) begin : g
    child a2 [2] (.p(arr), .o(o[1:0]));
  end
endmodule
