// § ifaceArrSliceElemName309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
interface outer (ifc p);
  logic t;
  assign t = p.sig[0];
endinterface
module top (output logic o);
  ifc arr [2] ();
  outer oa [2] (.p(arr));
  assign o = oa[1].t;
endmodule
