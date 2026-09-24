package p;
  typedef struct packed { int unsigned DAT; } cfg_t;
endpackage
interface bus_if #(parameter p::cfg_t CFG = '{DAT: 8});
  logic [CFG.DAT-1:0] data;
endinterface
module reader (bus_if s, output logic [31:0] w);
  assign w = 32'(s.CFG.DAT);
endmodule
module top (output logic [31:0] w);
  bus_if #('{DAT: 12}) arr [1:0] ();
  reader u (.s(arr[0]), .w(w));
endmodule
