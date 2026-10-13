// § ifaceArrSliceElemName309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module sink (ifc q [2], output logic o);
  assign o = q[1].sig[0];
endmodule
module top (output logic [2:0] o);
  ifc arr [2] ();
  child a2 [2] (.p(arr), .o(o[1:0]));
  sink s (.q(arr), .o(o[2]));
endmodule
