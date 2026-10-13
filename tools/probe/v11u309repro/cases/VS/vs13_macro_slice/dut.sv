// § ifaceArrSliceElemName309
`define ARR arr
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module top (output logic [1:0] o);
  ifc arr [2] ();
  child a2 [2] (.p(`ARR), .o(o));
endmodule
