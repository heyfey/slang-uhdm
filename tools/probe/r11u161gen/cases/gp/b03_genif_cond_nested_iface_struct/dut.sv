// r11u161 gen path: nested gen-if conditions reading an interface-port struct-parameter field (SEL)
package p;
  typedef struct packed { int unsigned DLY; } hsk_t;
  typedef struct packed { hsk_t HSK; } cfg_t;
  localparam cfg_t CFG_DEF = '{HSK: '{DLY: 1}};
endpackage
interface bus_if #(parameter p::cfg_t CFG = p::CFG_DEF);
  logic [3:0] d;
endinterface
module child (bus_if sub, output logic [3:0] o);
  if (sub.CFG.HSK.DLY > 0) begin : g
    if (sub.CFG.HSK.DLY == 1) begin : h
      assign o = sub.d;
    end
  end
endmodule
module top (input logic [3:0] s, output logic [3:0] o);
  bus_if b ();
  assign b.d = s;
  child c (.sub(b), .o(o));
endmodule
