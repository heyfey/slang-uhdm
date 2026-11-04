// § portViewParamDefName130
package p;
  typedef struct packed { int unsigned DLY; } cfg_t;
endpackage
interface my_iface #(parameter p::cfg_t CFG = 32'd5);
  logic [3:0] data;
endinterface
module sub (my_iface bus);
  assign bus.data = '0;
endmodule
module top;
  my_iface bus();
  sub u_sub(.bus(bus));
endmodule
