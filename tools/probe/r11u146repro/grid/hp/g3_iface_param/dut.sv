// § constPathBaseAnyKind146
package p;
  typedef struct { int unsigned DAT; } bus_t;
  typedef struct { bus_t BUS; } cfg_t;
endpackage
interface tif #(parameter p::cfg_t CFG = '{BUS: '{DAT: 8}});
  logic [CFG.BUS.DAT-1:0] data;
endinterface
module top(output logic [7:0] o);
  tif i();
  assign o = i.data;
endmodule
