// § defAggParamBindsImportClone232
package p;
  typedef struct packed {
    int unsigned a;
    bit f;
  } cfg_t;
  typedef union packed {
    logic [32:0] w;
    cfg_t       c;
  } cu_t;
  localparam cfg_t C = '{a: 5, f: 1};
endpackage
module m_a(output logic o);
  import p::*;
  parameter cfg_t A = '0;
  assign o = A.f;
endmodule
module m_z(output logic o);
  import p::*;
  parameter cfg_t Z = 33'd3;
  assign o = Z.f;
endmodule
module top(output logic o1, output logic o2);
  m_a a (.o(o1));
  m_z z (.o(o2));
endmodule
