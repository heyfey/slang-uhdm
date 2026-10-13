// § ifaceArrSliceElemName309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module mid (ifc arr [2], output logic [1:0] o);
  child a2 [2] (.p(arr), .o(o));
endmodule
module top (output logic [1:0] o);
  ifc arr [2] ();
  mid u (.arr(arr), .o(o));
endmodule
