// § hpBaseSelMidMemberBare133
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
  typedef struct packed {
    e_t f;
    logic [1:0] k;
  } w_t;
  typedef struct packed {
    w_t g;
  } z_t;
endpackage
interface ifc;
  p::w_t w;
endinterface
module dut(input logic [6:0] flat, output logic o);
  ifc u[2]();
  assign u[0].w = flat;
  assign u[1].w = ~flat;
  assign o = u[1].w.f.valid;
endmodule
