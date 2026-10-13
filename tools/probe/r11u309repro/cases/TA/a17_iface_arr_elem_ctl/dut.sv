// § ifaceTailDupArrayChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface

module child (ifc.mp p, output logic o);
  assign o = p.sig[0];
endmodule

module top (output logic [3:0] o);
  ifc arr [2] ();
  child a1 [2] (.p(arr[0]), .o(o[1:0]));
endmodule
