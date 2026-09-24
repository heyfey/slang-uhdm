package p;
  typedef struct packed { int unsigned DAT; } cfg_t;
endpackage
interface bus_if #(parameter p::cfg_t CFG = '{DAT: 8}, parameter int W = 2);
  logic [CFG.DAT-1:0] data;
  modport mp (input data);
endinterface
module reader (bus_if.mp s, output logic [31:0] w);
  assign w = 32'(s.CFG.DAT) * s.W;
endmodule
module top (output logic [31:0] w);
  bus_if #(.W(7)) arr [2] ();
  reader u (.s(arr[0]), .w(w));
endmodule
