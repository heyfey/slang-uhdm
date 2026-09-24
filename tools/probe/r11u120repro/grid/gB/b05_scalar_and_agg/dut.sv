package p;
  typedef struct packed { int unsigned DAT; } cfg_t;
endpackage
interface bus_if #(parameter int W = 4, parameter p::cfg_t CFG = '{DAT: 8});
  logic [W-1:0] data;
  modport mp (input data);
endinterface
module reader (bus_if.mp s, output logic [31:0] w, output logic [31:0] v);
  assign w = 32'(s.CFG.DAT);
  assign v = 32'(s.W);
endmodule
module top (output logic [31:0] w, output logic [31:0] v);
  bus_if #(.W(6), .CFG('{DAT: 16})) arr [1:0] ();
  reader u (.s(arr[0]), .w(w), .v(v));
endmodule
