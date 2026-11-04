package p;
  typedef struct packed { int unsigned A; int unsigned B; } cfg_t;
endpackage
interface bus_if #(parameter p::cfg_t CFG = '{A: 8, B: 4});
  logic [CFG.A-1:0] data;
  modport mp (input data);
endinterface
module reader (bus_if.mp s, output logic [31:0] w);
  assign w = 32'(s.CFG.B);
endmodule
module top (output logic [31:0] w);
  localparam p::cfg_t CX = '{A: 16, B: 2};
  bus_if #(CX) arr [1:0] ();
  reader u (.s(arr[0]), .w(w));
endmodule
