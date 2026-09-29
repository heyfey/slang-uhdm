// § hpVarSelRangeIdxNamesByPath220
interface bus;
  typedef struct packed { logic [15:0] vpn; logic [1:0][3:0] pg; logic v; } s_t;
  s_t [1:0] tq;
  logic [1:0] ix;
  logic [1:0] o;
  assign o = tq[1].pg[ix-1][1:0];
endinterface
module top(output logic [1:0] o);
  bus b();
  assign o = b.o;
endmodule
