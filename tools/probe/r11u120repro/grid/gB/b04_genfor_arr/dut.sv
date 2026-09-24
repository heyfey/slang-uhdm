package p;
  typedef struct packed { int unsigned DAT; } cfg_t;
endpackage
interface bus_if #(parameter p::cfg_t CFG = '{DAT: 8});
  logic [CFG.DAT-1:0] data;
  modport mp (input data);
endinterface
module reader (bus_if.mp s, output logic [31:0] w);
  assign w = 32'(s.CFG.DAT);
endmodule
module top (output logic [63:0] w);
  bus_if #('{DAT: 16}) arr [1:0] ();
  for (genvar i = 0; i < 2; i++) begin : g
    reader u (.s(arr[i]), .w(w[i*32 +: 32]));
  end
endmodule
