// v85 adversarial arm A10 — the shape in classes, functions, packages, enums,
// struct defaults, for-loop bounds and defparam.
package z85_pkg;
  parameter int PW = 5;
  localparam logic [31:0] PMASK = ~(('h1 << PW) - 1'b1);
  localparam int PSH = ('h1 << PW);
  typedef enum logic [31:0] { E0 = ~(('h1 << 1) - 1'b1), E1 = 32'h2 } e_t;
  typedef struct packed { logic [7:0] f; } s_t;
endpackage
class C85 #(parameter int CW = 4);
  localparam logic [31:0] CM = ~(('h1 << CW) - 1'b1);
  function automatic int f85(int x = ~(('h1 << 2) - 1'b1));
    int y;
    localparam int LF = ~(('h1 << 3) - 1'b1);
    y = ~(('h1 << x) - 1'b1);
    for (int i = 0; i < ('h1 << 2); i++) y = y + i;
    return y + LF;
  endfunction
endclass
module vaA_misc85 #(parameter int W = 4) ();
  import z85_pkg::*;
  localparam logic [31:0] M1 = PMASK;
  localparam logic [31:0] M2 = ~(('h1 << PW) - 1'b1);
  function automatic int g85(int a);
    localparam int LG = ~(('h1 << 3) - 1'b1);
    return a ^ LG;
  endfunction
  localparam int M3 = g85(1);
  z85_pkg::s_t s1;
  initial begin
    int k;
    k = ~(('h1 << W) - 1'b1);
    for (int i = 0; i < ('h1 << 2); i++) k++;
  end
endmodule
