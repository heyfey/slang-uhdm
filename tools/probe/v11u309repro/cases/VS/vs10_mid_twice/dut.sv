// § ifaceArrSliceElemName309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule
module mid (output logic [1:0] o);
  ifc arr [2] ();
  child a2 [2] (.p(arr), .o(o));
endmodule
module top (output logic [3:0] o);
  mid m0 (.o(o[1:0]));
  mid m1 (.o(o[3:2]));
endmodule
