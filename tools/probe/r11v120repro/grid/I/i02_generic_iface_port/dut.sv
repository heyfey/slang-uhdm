package p;
  typedef struct packed { int unsigned DAT; } cfg_t;
endpackage
interface bus_if #(parameter p::cfg_t CFG = '{DAT: 8}, parameter int K = 3);
  logic [CFG.DAT-1:0] data;
endinterface
module reader (bus_if s, output logic [31:0] w);
  assign w = 32'(s.CFG.DAT) + s.K;
endmodule
module top (output logic [31:0] w);
  bus_if #(.CFG('{DAT: 12}), .K(5)) b ();
  reader u (.s(b), .w(w));
endmodule
