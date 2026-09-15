// r11u39 arm a3 — LVALUE position, genvar and package-parameter indices, and a
// CLASS BODY, for the trailing member multi-select element.
package p3;
  localparam int PK = 1;
  typedef struct packed { logic a; logic b; } leaf_t;
  typedef struct packed {
    logic [3:0][1:0]  sat;
    leaf_t [3:0][1:0] lv;      // struct element -> a member can FOLLOW the
                               // two-step select (the MID cell)
    logic             v;
  } e_t;
endpackage

module dut (
    input  logic        r_i, c_i,
    input  logic [1:0]  s_i,
    input  logic [255:0] flat_i,
    output logic [3:0]  ov,
    output logic        gv, cv
);
  localparam int MP = 1;
  p3::e_t [1:0][1:0] tb, wb;
  p3::e_t [1:0][1:0] wv;
  p3::e_t            m0;      // root NOT selected: the MID/TRAIL cells whose
                              // base chain bottoms out at a BARE name
  logic [1:0][1:0][8:0] raw;

  assign tb = flat_i[71:0];

  // CONT-ASSIGN LVALUE, trailing member multi-select (constant indices --
  // a non-constant select is ILLEGAL on a continuous-assign lvalue, so the
  // dynamic lvalue cell lives in the process below).
  assign wb[0][1].sat[2][0] = flat_i[1];
  assign wb[1][0].sat[MP][1] = flat_i[3];
  // MID-PATH LVALUE in a CONT-ASSIGN
  assign wb[1][1].lv[0][1].a = flat_i[8];

  // PROCESS LVALUE and RVALUE
  always_comb begin
    ov = '0;
    ov[0] = tb[r_i][c_i].sat[s_i][1];          // rvalue
    ov[1] = tb[r_i][c_i].sat[MP][0];           // module localparam index
    ov[2] = tb[r_i][c_i].sat[p3::PK][1];       // PACKAGE localparam index
    ov[3] = tb[r_i][c_i].sat[s_i][MP];
    // PROCESS LVALUE, dynamic trailing member multi-select
    wv[r_i][c_i].sat[s_i][1] = flat_i[4];
    wv[0][1].sat[2][0]       = flat_i[5];
    // MID-PATH LVALUE: a member BELOW a two-step member select
    wv[r_i][c_i].lv[s_i][1].b = flat_i[6];
    wv[0][1].lv[2][0].a       = flat_i[7];
    // ROOT NOT SELECTED, MID member with TWO steps (lvalue and rvalue)
    m0.lv[s_i][1].a = flat_i[9];
    ov[0]           = m0.lv[s_i][1].b;
    // ROOT NOT SELECTED, TRAILING member with TWO steps (lvalue and rvalue)
    m0.sat[s_i][1]  = flat_i[10];
    ov[1]           = m0.sat[s_i][0];
  end

  // GENVAR index on the member tail and on the root
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gb
      logic w;
      assign w = tb[gi][c_i].sat[gi][1];
    end
  endgenerate
  assign gv = gb[0].w;

  // CLASS BODY
  class C;
    p3::e_t [1:0][1:0] q;
    function automatic logic rd(input logic [1:0] k);
      return q[0][1].sat[k][1];
    endfunction
    task automatic wr(input logic [1:0] k);
      q[0][1].sat[k][1] = 1'b1;
    endtask
  endclass
  assign cv = flat_i[2];
endmodule
