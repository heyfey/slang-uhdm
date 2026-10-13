// § ifaceArrSliceElemName309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, input logic e, output logic o);
  assign o = p.sig[0] & e;
endmodule
module top (input logic e, output logic [1:0] o);
  ifc arr [2] ();
  child a2 [2] (arr, e, o);
endmodule
