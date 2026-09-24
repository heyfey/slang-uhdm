package p;
  typedef struct packed { int unsigned DAT; } cfg_t;
  typedef struct packed { int unsigned A; int unsigned B; } cfg2_t;
endpackage
interface bus_if #(parameter p::cfg_t CFG = '{DAT: 8});
  logic [CFG.DAT-1:0] data;
  modport mp (input data);
endinterface
module reader #(parameter int ID = 0) (bus_if.mp s, output logic [31:0] w);
  assign w = 32'(s.CFG.DAT) + ID;
endmodule
module top (output logic [31:0] w);
  localparam p::cfg_t C16 = '{DAT: 16};
  bus_if #(C16) b ();
  reader #(.ID(0)) u (.s(b), .w(w));
endmodule
