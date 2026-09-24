package p;
  typedef struct packed { int unsigned A; int unsigned B; } cfg_t;
endpackage
interface bus_if #(parameter p::cfg_t CFG = '{A: 3, B: 5});
  logic [CFG.A-1:0] data;
  modport mp (input data);
endinterface
module reader (bus_if.mp s, output logic [31:0] w);
  assign w = 32'(s.CFG.B);
endmodule
module top (output logic [31:0] w);
  bus_if #('{A: 4, B: 9}) arr [1:0] ();
  reader u (.s(arr[1]), .w(w));
endmodule
