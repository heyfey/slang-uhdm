// § pkgImpPackedArrElemCopy240: a struct holding an enum and a packed array member, the parameter selected in a part-select bound and a generate
package cp;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  typedef struct packed {
    e_t kind;
    logic [1:0][3:0] lanes;
  } ps_t;
  parameter ps_t [1:0] allc = '{'{E1, 8'h21}, '{E2, 8'h43}};
endpackage
package bp;
  import cp::*;
  localparam int N = 2;
endpackage
module top
  import cp::*;
  import bp::*;
 (input logic [15:0] i, output logic [3:0] o);
  assign o = i[allc[0].lanes[1] +: 4];
  for (genvar g = 0; g < N; g++) begin : gb
    if (allc[g].kind == E1) begin : hit
      wire w = i[g];
    end
  end
endmodule
