// r10v61 ADVERSARIAL GRID 4 — law B carriers other than the module-level
// cont_assign: gen-scope cont_assign, cont_assign inside an interface, an
// unpacked-array cont_assign, a union member, and the DEFAULT-half controls.
package px61;
  typedef struct packed {
    logic [2:0] w3;
    logic       w1;
    logic [7:0] w8;
  } t61_t;
  typedef struct packed { logic [11:0] all; } u61_t;
endpackage

interface ix61 (input logic clk);
  import px61::*;
  t61_t ib;
  assign ib = '{ w3 : '1, w1 : '0, w8 : '1 };
endinterface

module v4_v61 (input logic clk, output px61::t61_t o1, output px61::t61_t o2,
               output px61::u61_t o3, output logic o4);
  import px61::*;
  parameter bit EN = 1;
  t61_t ga;
  t61_t ua [1:0];
  ix61 bus (.clk(clk));

  // D1: cont_assign INSIDE a generate block
  if (EN) begin : gen_ca
    t61_t gl;
    assign gl = '{ w3 : '1, w1 : 'x, w8 : '0 };
    assign ga = gl;
  end
  assign o1 = ga;

  // D2: cont_assign whose RHS pattern is nested inside a ternary
  assign o2 = clk ? '{ w3 : '1, w1 : '0, w8 : '1 }
                  : '{ w3 : '0, w1 : '1, w8 : '0 };

  // D3: a UNION-typed target
  assign o3 = '{ all : '1 };

  // D4: unpacked array of structs by cont_assign
  assign ua = '{ '{ w3 : '1, w1 : '0, w8 : 'x },
                 '{ w3 : '0, w1 : '1, w8 : '1 } };
  assign o4 = ua[0].w1 ^ bus.ib.w1;
endmodule
