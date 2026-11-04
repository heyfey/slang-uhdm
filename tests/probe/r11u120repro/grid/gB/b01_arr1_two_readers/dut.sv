package p;
  typedef struct packed { int unsigned DAT; } cfg_t;
endpackage
interface bus_if #(parameter p::cfg_t CFG = '{DAT: 8});
  logic [CFG.DAT-1:0] data;
  modport mp (input data);
endinterface
module reader #(parameter int ID = 0) (bus_if.mp s, output logic [31:0] w);
  assign w = 32'(s.CFG.DAT) + ID;
endmodule
module top (output logic [31:0] w0, output logic [31:0] w1);
  localparam p::cfg_t C16 = '{DAT: 16};
  bus_if #(C16) arr [2-1:0] ();
  reader #(.ID(0)) u0 (.s(arr[0]), .w(w0));
  reader #(.ID(1)) u1 (.s(arr[1]), .w(w1));
endmodule
