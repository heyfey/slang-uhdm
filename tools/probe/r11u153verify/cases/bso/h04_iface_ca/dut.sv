// § hpBaseSelOpIdxNamesByPath145
typedef struct packed { logic v; logic [3:0] r; } s_t;
interface ifc;
  localparam D = 2;
  s_t [1:0] sd;
  logic o;
  assign o = sd[D-1].v;
endinterface
module dut(output logic o);
  ifc i();
  assign o = i.o;
endmodule
