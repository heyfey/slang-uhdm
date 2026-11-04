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
module dut(input logic [13:0] flat, output logic [1:0] o);
  p::w_t [1:0] tbl;
  assign tbl = flat;
  for (genvar g = 0; g < 2; g++) begin : gb
    assign o[g] = tbl[g].f.valid;
  end
endmodule
