// § portViewParamDefName130
package p;
  typedef struct packed { int unsigned DLY; } cfg_t;
  localparam cfg_t CFG_DEF = '{DLY: 1};
endpackage
interface my_iface #(parameter p::cfg_t CFG = p::CFG_DEF);
  logic [3:0] data;
endinterface
module sub (my_iface bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface bus();
  sub u_sub(.bus(bus));
endmodule
