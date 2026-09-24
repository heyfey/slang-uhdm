// § hpTrailSelIdxNamesByPath133
package p;
  typedef struct packed {
    logic       valid;
    logic [3:0] sat;
  } e_t;
  typedef struct packed {
    e_t f;
    logic [1:0] k;
  } w_t;
endpackage
interface ifc(input logic [1:0] i, input logic [4:0] flat);
  p::e_t s;
  assign s = flat;
  logic o;
  assign o = s.sat[i];
endinterface
module dut(input logic [1:0] i, input logic [4:0] flat, output logic o);
  ifc u(.i(i), .flat(flat));
  assign o = u.o;
endmodule
