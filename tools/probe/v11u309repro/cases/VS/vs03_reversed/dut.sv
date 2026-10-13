// § ifaceArrSliceElemName309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  ifc arr [0:1] ();
  child a2 [1:0] (.p(arr), .o(o));
endmodule
